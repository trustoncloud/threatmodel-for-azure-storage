package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
required_lock_accounts := {"exampleprodstorage01", "examplebilling"}
valid_lock_levels := {"CanNotDelete", "ReadOnly"}

# --- Helpers ---
# The local name in a reference "${<prefix>.<name>.<attr>}", matched exactly.
tf_ref_name(v, prefix, attr) := name {
    is_string(v)
    m := regex.find_all_string_submatch_n(sprintf(`^\$\{\s*%s\.([A-Za-z0-9_-]+)(?:\[[^\]]*\])?\.%s\s*\}$`, [replace(prefix, ".", `\.`), attr]), v, 1)
    name := m[0][1]
}

tf_literal(v) {
    is_string(v)
    not tocm_tf_unresolved(v)
}

# The lowercased segments of a literal Azure resource ID.
tf_id_parts(v) := parts {
    tf_literal(v)
    parts := split(tocm_azure_id_norm(v), "/")
}

# The provider configuration a resource or data source uses: "azurerm" when
# omitted or named without an alias, "azurerm.<alias>" otherwise.
tf_provider(r) := p {
    v := object.get(r, "provider", "azurerm")
    is_string(v)
    p := trim_space(trim_suffix(trim_prefix(trim_space(v), "${"), "}"))
} else := "unknown"

# The account, the lock and the resource group or subscription source use the
# same provider configuration, so they sit in the same subscription.
tf_same_provider(resource, lock, source) {
    p := tf_provider(resource)
    p != "unknown"
    tf_provider(lock) == p
    tf_provider(source) == p
}

# Lock scoped to the account itself, by reference or by its literal ID.
tf_lock_covers(document, resource, name, lock) {
    tf_ref_name(lock.scope, "azurerm_storage_account", "id") == name
}

tf_lock_covers(document, resource, name, lock) {
    parts := tf_id_parts(lock.scope)
    count(parts) == 9
    parts[3] == "resourcegroups"
    parts[5] == "providers"
    parts[6] == "microsoft.storage"
    parts[7] == "storageaccounts"
    tf_literal(resource.name)
    parts[8] == lower(resource.name)
}

# Lock scoped to the account's resource group, declared as a resource or read
# by a data source in this document.
tf_lock_covers(document, resource, name, lock) {
    rg := tf_ref_name(lock.scope, "azurerm_resource_group", "id")
    group := document.resource.azurerm_resource_group[rg]
    tf_same_provider(resource, lock, group)
    tf_same_group(resource.resource_group_name, "azurerm_resource_group", rg, group)
}

tf_lock_covers(document, resource, name, lock) {
    rg := tf_ref_name(lock.scope, "data.azurerm_resource_group", "id")
    group := document.data.azurerm_resource_group[rg]
    tf_same_provider(resource, lock, group)
    tf_same_group(resource.resource_group_name, "data.azurerm_resource_group", rg, group)
}

# Lock scoped to the current subscription: a subscription data source that
# names no other subscription.
tf_lock_covers(document, resource, name, lock) {
    sub := tf_ref_name(lock.scope, "data.azurerm_subscription", "id")
    ds := document.data.azurerm_subscription[sub]
    tf_same_provider(resource, lock, ds)
    not tf_names_subscription(ds)
}

tf_names_subscription(ds) {
    ds.subscription_id
}

# The account's resource_group_name points at that group's name, or equals
# the group's literal name.
tf_same_group(rg_name, prefix, rg, _) {
    tf_ref_name(rg_name, prefix, "name") == rg
}

tf_same_group(rg_name, _, _, group) {
    tf_literal(rg_name)
    tf_literal(group.name)
    lower(rg_name) == lower(group.name)
}

tf_has_valid_lock(document, resource, name) {
    lock := document.resource.azurerm_management_lock[_]
    valid_lock_levels[lock.lock_level]
    tf_lock_covers(document, resource, name, lock)
}

# --- Logic ---
# Required accounts must have a CanNotDelete or ReadOnly management lock on
# the account, its resource group or the current subscription, declared in
# the same file.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    required_lock_accounts[resource.name]
    not tf_has_valid_lock(document, resource, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("required account has a management lock with level in %v on the account, its resource group or the current subscription", [valid_lock_levels]),
        "keyActualValue": sprintf("required account '%v' has no CanNotDelete or ReadOnly lock declared in this file; a lock declared elsewhere is not seen", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
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
