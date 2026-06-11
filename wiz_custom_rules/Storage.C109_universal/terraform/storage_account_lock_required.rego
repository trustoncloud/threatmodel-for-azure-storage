package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
valid_lock_levels := {"CanNotDelete", "ReadOnly"}

# --- Helpers ---
has_valid_lock(document, resource, name) {
    lock := document.resource.azurerm_management_lock[lockName]
    terraLib.associatedResources(resource, lock, name, lockName, null, "scope")
    valid_lock_levels[lock.lock_level]
}

# --- Logic ---
# Universal: every storage account must have a CanNotDelete or ReadOnly
# management lock. Fire when an account has no associated valid lock.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    not has_valid_lock(document, resource, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("every account must have a management lock with level in %v", [valid_lock_levels]),
        "keyActualValue": sprintf("account '%v' has no CanNotDelete/ReadOnly management lock", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
