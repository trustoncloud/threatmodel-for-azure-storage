package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Storage account names authorized to have Shared Key (SAS) access enabled.
allowed_sas_accounts := {
    "backup_storage_prod",
    "legacy_app_share",
}

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# --- Logic ---
# shared_access_key_enabled defaults to true (enabled), so the matcher checks
# two cases: explicitly enabled, and omitted (inherits the enabled default).
# Either, on a non-authorized account, is a violation.

# Surface 1: explicitly enabled on a non-authorized account
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    is_true(resource.shared_access_key_enabled)
    not allowed_sas_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].shared_access_key_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("shared_access_key_enabled must be false unless the account is authorized: %v", [allowed_sas_accounts]),
        "keyActualValue": sprintf("shared_access_key_enabled is true for unauthorized account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Surface 2: omitted on a non-authorized account -> inherits the enabled default
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    not terraLib.validKey(resource, "shared_access_key_enabled")
    not allowed_sas_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "shared_access_key_enabled must be explicitly set to false unless the account is authorized",
        "keyActualValue": sprintf("shared_access_key_enabled is unset for '%v' (defaults to true = enabled)", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
