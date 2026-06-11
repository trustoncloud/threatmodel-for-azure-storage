package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# --- Logic ---
# Universal: Shared Key (SAS) access must be disabled for every storage
# account. shared_access_key_enabled defaults to true, so the matcher fires
# on both the explicitly-enabled and the omitted (default-enabled) cases.

# Surface 1: explicitly enabled
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    is_true(resource.shared_access_key_enabled)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].shared_access_key_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "shared_access_key_enabled must be false for all storage accounts",
        "keyActualValue": sprintf("shared_access_key_enabled is true for account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Surface 2: omitted -> inherits the enabled default
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    not terraLib.validKey(resource, "shared_access_key_enabled")

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "shared_access_key_enabled must be explicitly set to false for all storage accounts",
        "keyActualValue": sprintf("shared_access_key_enabled is unset for '%v' (defaults to true = enabled)", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
