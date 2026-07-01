package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
required_lock_accounts := {"prod-storage-01", "billing-archive"}
valid_lock_levels := {"CanNotDelete", "ReadOnly"}

# --- Helpers ---
# True if a management lock in this document is scoped to the given account
# and uses a valid lock level.
has_valid_lock(document, resource, name) {
    lock := document.resource.azurerm_management_lock[lockName]
    terraLib.associatedResources(resource, lock, name, lockName, null, "scope")
    valid_lock_levels[lock.lock_level]
}

# --- Logic ---
# Required accounts must have a CanNotDelete or ReadOnly management lock.
# Fire when a required account has no associated valid lock in the document.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    required_lock_accounts[resource.name]
    not has_valid_lock(document, resource, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("required account must have a management lock with level in %v", [valid_lock_levels]),
        "keyActualValue": sprintf("required account '%v' has no CanNotDelete/ReadOnly management lock", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
