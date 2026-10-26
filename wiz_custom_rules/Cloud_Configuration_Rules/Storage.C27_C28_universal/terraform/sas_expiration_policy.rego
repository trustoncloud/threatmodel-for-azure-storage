package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
max_sas_expiration_period := "1.00:00:00"

require_sas_expiration_block := true

# --- Helpers ---
# shared_access_key_enabled defaults to true, so only an explicit false
# takes an account out of scope.
tf_shared_key_disabled(resource) {
    terraLib.validKey(resource, "shared_access_key_enabled")
    resource.shared_access_key_enabled == false
}

tf_period_seconds(p) := secs {
    parts := split(p, ".")
    count(parts) == 2
    hms := split(parts[1], ":")
    secs := (((to_number(parts[0]) * 24) + to_number(hms[0])) * 60 + to_number(hms[1])) * 60 + to_number(hms[2])
} else := secs {
    hms := split(p, ":")
    count(hms) == 3
    secs := ((to_number(hms[0]) * 60) + to_number(hms[1])) * 60 + to_number(hms[2])
}

tf_sas_policy(resource) := policy {
    terraLib.validKey(resource, "sas_policy")
    policy := terraLib.getValueArrayOrObject(resource.sas_policy)
}

# --- Logic ---
# Finding: Shared Key is on and no sas_policy block is declared.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    not tf_shared_key_disabled(resource)
    not tf_sas_policy(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "MissingAttribute",
        "keyExpectedValue": sprintf("sas_policy with expiration_period at most %v", [max_sas_expiration_period]),
        "keyActualValue": "sas_policy is not set while Shared Key is enabled",
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: expiration_period longer than the maximum.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    not tf_shared_key_disabled(resource)
    policy := tf_sas_policy(resource)
    tf_period_seconds(policy.expiration_period) > tf_period_seconds(max_sas_expiration_period)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].sas_policy.expiration_period", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("expiration_period at most %v", [max_sas_expiration_period]),
        "keyActualValue": sprintf("expiration_period is %v", [policy.expiration_period]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: expiration_action is not Block (it defaults to Log).
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    require_sas_expiration_block
    not tf_shared_key_disabled(resource)
    policy := tf_sas_policy(resource)
    action := object.get(policy, "expiration_action", "Log")
    action != "Block"

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].sas_policy", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "expiration_action is Block",
        "keyActualValue": sprintf("expiration_action is %v", [action]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
