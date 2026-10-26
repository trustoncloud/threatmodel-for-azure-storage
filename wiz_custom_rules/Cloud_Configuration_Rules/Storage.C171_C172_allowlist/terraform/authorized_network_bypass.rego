package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
authorized_network_bypass := {"AzureServices"}

# --- Helpers ---
tf_unauthorized_bypass(values) := {v |
    v := terraLib.getArray(values)[_]
    is_string(v)
    v != "None"
    not authorized_network_bypass[v]
}

# --- Logic ---
# Finding: inline network_rules on the account use an unauthorized bypass.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "network_rules")
    rules := terraLib.getValueArrayOrObject(resource.network_rules)
    v := tf_unauthorized_bypass(object.get(rules, "bypass", ["AzureServices"]))[_]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].network_rules.bypass", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("bypass uses only %v", [authorized_network_bypass]),
        "keyActualValue": sprintf("bypass includes %v", [v]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: a standalone azurerm_storage_account_network_rules uses an
# unauthorized bypass.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account_network_rules[name]
    v := tf_unauthorized_bypass(object.get(resource, "bypass", ["AzureServices"]))[_]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_network_rules",
        "resourceName": name,
        "searchKey": sprintf("azurerm_storage_account_network_rules[%s].bypass", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("bypass uses only %v", [authorized_network_bypass]),
        "keyActualValue": sprintf("bypass includes %v", [v]),
        "resourceTags": {},
    }
}
