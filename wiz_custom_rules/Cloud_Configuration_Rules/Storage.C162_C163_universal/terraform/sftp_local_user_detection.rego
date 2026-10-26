package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# local_user_enabled defaults to true, so only an explicit false turns it off.
tf_sftp_local_users_on(resource) {
    is_true(resource.sftp_enabled)
    not resource.local_user_enabled == false
}

# --- Logic ---
# Finding: SFTP with local users on any account.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_sftp_local_users_on(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].sftp_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "SFTP with local users is disabled",
        "keyActualValue": sprintf("SFTP with local users is enabled on '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: a local user that may sign in with a password. Authorized local
# users sign in with SSH keys only.
WizPolicy[result] {
    document := input.document[i]
    user := document.resource.azurerm_storage_account_local_user[name]
    is_true(user.ssh_password_enabled)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_local_user",
        "resourceName": terraLib.get_resource_name(user, name),
        "searchKey": sprintf("azurerm_storage_account_local_user[%s].ssh_password_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "ssh_password_enabled is false; local users sign in with SSH keys",
        "keyActualValue": "ssh_password_enabled is true",
        "resourceTags": {},
    }
}
