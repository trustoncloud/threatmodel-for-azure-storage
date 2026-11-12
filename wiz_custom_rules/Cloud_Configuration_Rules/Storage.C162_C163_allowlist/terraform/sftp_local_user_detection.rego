package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
authorized_sftp_accounts := {"examplevendorupload", "examplelegacyftp"}

# Local users allowed on those accounts, as "<account name>/<local user name>".
authorized_local_users := {"examplevendorupload/examplevendor"}

# Permissions a local user may hold in any permission scope.
allowed_local_user_permissions := {"read", "list", "write", "create"}

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

tf_local_user_permission_names := ["read", "list", "write", "create", "delete"]

# local_user_enabled defaults to true, so only an explicit false turns it off.
tf_sftp_local_users_on(resource) {
    is_true(resource.sftp_enabled)
    not resource.local_user_enabled == false
}

# The account a local user belongs to: a reference to an account declared in
# this document gives that account's name; a literal ID gives its last segment.
tf_user_account(document, user) := acct {
    ref := object.get(user, "storage_account_id", "")
    is_string(ref)
    m := regex.find_all_string_submatch_n(`^\$\{\s*azurerm_storage_account\.([A-Za-z0-9_-]+)(?:\[[^\]]*\])?\.id\s*\}$`, ref, 1)
    account := document.resource.azurerm_storage_account[m[0][1]]
    is_string(account.name)
    not tocm_tf_unresolved(account.name)
    acct := lower(account.name)
} else := acct {
    ref := object.get(user, "storage_account_id", "")
    not tocm_tf_unresolved(ref)
    parts := split(tocm_azure_id_norm(ref), "/")
    count(parts) == 9
    parts[3] == "resourcegroups"
    parts[5] == "providers"
    parts[6] == "microsoft.storage"
    parts[7] == "storageaccounts"
    acct := parts[8]
}

tf_authorized_account(acct) {
    lower(authorized_sftp_accounts[_]) == acct
}

tf_authorized_user(acct, user) {
    is_string(user.name)
    not tocm_tf_unresolved(user.name)
    lower(authorized_local_users[_]) == sprintf("%s/%s", [acct, lower(user.name)])
}

tf_user_label(user, name) := user.name {
    is_string(user.name)
} else := name

# --- Logic ---
# Finding: SFTP with local users on an account that is not authorized.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_sftp_local_users_on(resource)
    not authorized_sftp_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].sftp_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("SFTP with local users only on %v", [authorized_sftp_accounts]),
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

# Finding: the local user's account is not resolved by this source scan.
WizPolicy[result] {
    document := input.document[i]
    user := document.resource.azurerm_storage_account_local_user[name]
    not tf_user_account(document, user)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_local_user",
        "resourceName": terraLib.get_resource_name(user, name),
        "searchKey": sprintf("azurerm_storage_account_local_user[%s].storage_account_id", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("storage_account_id names an account in %v", [authorized_sftp_accounts]),
        "keyActualValue": sprintf("storage_account_id '%v' is not resolved by this source scan", [object.get(user, "storage_account_id", "")]),
        "resourceTags": {},
    }
}

# Finding: a local user on an account that is not authorized for SFTP.
WizPolicy[result] {
    document := input.document[i]
    user := document.resource.azurerm_storage_account_local_user[name]
    acct := tf_user_account(document, user)
    not tf_authorized_account(acct)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_local_user",
        "resourceName": terraLib.get_resource_name(user, name),
        "searchKey": sprintf("azurerm_storage_account_local_user[%s].storage_account_id", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("local users only on %v", [authorized_sftp_accounts]),
        "keyActualValue": sprintf("local user '%v' is on account '%v', which is not authorized", [tf_user_label(user, name), acct]),
        "resourceTags": {},
    }
}

# Finding: a local user that is not in the authorized list.
WizPolicy[result] {
    document := input.document[i]
    user := document.resource.azurerm_storage_account_local_user[name]
    acct := tf_user_account(document, user)
    tf_authorized_account(acct)
    not tf_authorized_user(acct, user)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_local_user",
        "resourceName": terraLib.get_resource_name(user, name),
        "searchKey": sprintf("azurerm_storage_account_local_user[%s].name", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("local user is one of %v", [authorized_local_users]),
        "keyActualValue": sprintf("local user '%v/%v' is not authorized", [acct, tf_user_label(user, name)]),
        "resourceTags": {},
    }
}

# Finding: a permission scope grants a permission outside the allowed set.
WizPolicy[result] {
    document := input.document[i]
    user := document.resource.azurerm_storage_account_local_user[name]
    scope := terraLib.getArray(user.permission_scope)[sidx]
    perms := terraLib.getValueArrayOrObject(scope.permissions)
    perm := tf_local_user_permission_names[_]
    is_true(object.get(perms, perm, false))
    not allowed_local_user_permissions[perm]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_local_user",
        "resourceName": terraLib.get_resource_name(user, name),
        "searchKey": sprintf("azurerm_storage_account_local_user[%s].permission_scope[%d].permissions.%s", [name, sidx, perm]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("local user permissions are within %v", [allowed_local_user_permissions]),
        "keyActualValue": sprintf("local user '%v' has the '%v' permission", [tf_user_label(user, name), perm]),
        "resourceTags": {},
    }
}

# --- Matching helpers ---
# --- toc-match begin: azureid v1 ---
# Azure resource IDs compare case-insensitively, segment by segment.
tocm_azure_id_norm(id) := n {
    is_string(id)
    n := lower(trim_suffix(trim_space(id), "/"))
    startswith(n, "/subscriptions/")
    not contains(n, "//")
}

tocm_azure_id_equal(a, b) {
    tocm_azure_id_norm(a) == tocm_azure_id_norm(b)
}

tocm_azure_id_allowed(id, allowed) {
    tocm_azure_id_equal(id, allowed[_])
}
# --- toc-match end: azureid v1 ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
