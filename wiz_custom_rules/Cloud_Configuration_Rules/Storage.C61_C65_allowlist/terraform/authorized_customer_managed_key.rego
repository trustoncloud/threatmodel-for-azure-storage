package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
authorized_key_urls := {
    "https://examplevault.vault.azure.net/keys/examplestoragekey"
}

# --- Helpers ---
tf_authorized_lower := {trim_suffix(lower(u), "/") | u := authorized_key_urls[_]}

# A reference to another resource (${...}) resolves only at apply time, so
# only literal key IDs are judged.
tf_literal(v) {
    is_string(v)
    v != ""
    not contains(v, "${")
}

# https://<vault>/keys/<name>[/<version>] to its versionless form.
tf_versionless(id) := url {
    parts := split(trim_suffix(lower(id), "/"), "/")
    count(parts) >= 5
    url := concat("/", array.slice(parts, 0, 5))
}

tf_unauthorized(id) {
    tf_literal(id)
    not tf_authorized_lower[tf_versionless(id)]
}

# --- Logic ---
# Finding: the account's inline customer_managed_key names an unauthorized key.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "customer_managed_key")
    cmk := terraLib.getValueArrayOrObject(resource.customer_managed_key)
    attr := ["key_vault_key_id", "managed_hsm_key_id"][_]
    id := object.get(cmk, attr, "")
    tf_unauthorized(id)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].customer_managed_key.%s", [name, attr]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("customer-managed key is one of %v", [authorized_key_urls]),
        "keyActualValue": sprintf("%v is %v", [attr, id]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: a standalone azurerm_storage_account_customer_managed_key names an
# unauthorized key by its key ID.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account_customer_managed_key[name]
    attr := ["key_vault_key_id", "managed_hsm_key_id"][_]
    id := object.get(resource, attr, "")
    tf_unauthorized(id)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_customer_managed_key",
        "resourceName": name,
        "searchKey": sprintf("azurerm_storage_account_customer_managed_key[%s].%s", [name, attr]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("customer-managed key is one of %v", [authorized_key_urls]),
        "keyActualValue": sprintf("%v is %v", [attr, id]),
        "resourceTags": {},
    }
}
