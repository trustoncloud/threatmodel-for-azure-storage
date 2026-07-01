package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
authorized_sftp_accounts := {"vendor-upload-share", "legacy-ftp-bridge"}

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# --- Logic ---
# SFTP and local users must be enabled only on authorized accounts. Both are
# account-level attributes. Fire on an explicitly enabled attribute on a
# non-authorized account.

# SFTP enabled on a non-authorized account
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    is_true(resource.sftp_enabled)
    not authorized_sftp_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].sftp_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("sftp_enabled must be false unless the account is authorized: %v", [authorized_sftp_accounts]),
        "keyActualValue": sprintf("sftp_enabled is true on unauthorized account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Local users enabled on a non-authorized account
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    is_true(resource.local_user_enabled)
    not authorized_sftp_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].local_user_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("local_user_enabled must be false unless the account is authorized: %v", [authorized_sftp_accounts]),
        "keyActualValue": sprintf("local_user_enabled is true on unauthorized account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
