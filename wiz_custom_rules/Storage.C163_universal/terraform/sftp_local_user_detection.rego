package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# --- Logic ---
# Universal: SFTP and local users must be disabled for every storage account
# (Entra ID-only access). Fire on an explicitly enabled attribute.

# SFTP enabled
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    is_true(resource.sftp_enabled)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].sftp_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "sftp_enabled must be false for all storage accounts",
        "keyActualValue": sprintf("sftp_enabled is true on account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Local users enabled
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    is_true(resource.local_user_enabled)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].local_user_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "local_user_enabled must be false for all storage accounts",
        "keyActualValue": sprintf("local_user_enabled is true on account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
