package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
required_secure_accounts := {"finance-archive", "audit-logs", "prod-customer-data"}

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }
is_false(v) { v == false } else { v == "false" }

shared_key_disabled(resource) {
    terraLib.validKey(resource, "shared_access_key_enabled")
    is_false(resource.shared_access_key_enabled)
}

oauth_default(resource) {
    terraLib.validKey(resource, "default_to_oauth_authentication")
    is_true(resource.default_to_oauth_authentication)
}

# --- Logic ---
# Required accounts must disable Shared Key AND default to OAuth. Both fields
# default to the insecure value, so "not explicitly secure" (wrong or unset)
# is a violation.

# Required account without Shared Key disabled
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    required_secure_accounts[resource.name]
    not shared_key_disabled(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].shared_access_key_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "shared_access_key_enabled must be false for required accounts",
        "keyActualValue": sprintf("required account '%v' does not disable Shared Key (enabled or unset)", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Required account without OAuth default
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    required_secure_accounts[resource.name]
    not oauth_default(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].default_to_oauth_authentication", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "default_to_oauth_authentication must be true for required accounts",
        "keyActualValue": sprintf("required account '%v' does not default to OAuth (false or unset)", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
