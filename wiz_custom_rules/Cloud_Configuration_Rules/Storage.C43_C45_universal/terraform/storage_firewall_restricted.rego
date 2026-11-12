package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
# The parts of a whole-value reference such as "${azurerm_storage_account.sa.id}".
tf_ref_parts(v) := parts {
    is_string(v)
    m := regex.find_all_string_submatch_n(`^\$\{([^${}]+)\}$`, trim_space(v), 1)
    count(m) == 1
    parts := [p | q := split(m[0][1], ".")[_]; p := regex.replace(q, `\[[^\]]*\]$`, "")]
}

# storage_account_id names this account: a reference to it, or its literal ID.
tf_names_account(ref, name, _) {
    parts := tf_ref_parts(ref)
    count(parts) == 3
    parts[0] == "azurerm_storage_account"
    parts[1] == name
    parts[2] == "id"
}

tf_names_account(ref, _, resource) {
    seg := split(tocm_azure_id_norm(ref), "/")
    count(seg) == 9
    seg[3] == "resourcegroups"
    seg[5] == "providers"
    seg[6] == "microsoft.storage"
    seg[7] == "storageaccounts"
    is_string(resource.name)
    is_string(resource.resource_group_name)
    seg[4] == lower(resource.resource_group_name)
    seg[8] == lower(resource.name)
}

# True if a standalone azurerm_storage_account_network_rules resource in this
# document is linked to the given account (via storage_account_id).
tf_has_associated_network_rules(document, resource, name) {
    standalone := document.resource.azurerm_storage_account_network_rules[_]
    tf_names_account(object.get(standalone, "storage_account_id", ""), name, resource)
}

# --- Logic ---
# Universal: the firewall must have default_action 'Deny' and no ip_rules.
# Scan the inline block, the standalone resource, and the absence case.

# Surface 1 (inline): default_action = Allow (public)
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    nr := terraLib.getValueArrayOrObject(resource.network_rules)
    nr.default_action == "Allow"

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].network_rules.default_action", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "network_rules.default_action must be 'Deny'",
        "keyActualValue": "network_rules.default_action is 'Allow' (public)",
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Surface 1 (inline): any ip_rule present
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    nr := terraLib.getValueArrayOrObject(resource.network_rules)
    ip := nr.ip_rules[idx]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].network_rules.ip_rules[%d]", [name, idx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "network_rules.ip_rules must be empty",
        "keyActualValue": sprintf("network_rules.ip_rules[%d] is '%v' (no IP rules permitted)", [idx, ip]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Surface 2 (standalone): default_action = Allow (public)
WizPolicy[result] {
    document := input.document[i]
    standalone := document.resource.azurerm_storage_account_network_rules[sName]

    standalone.default_action == "Allow"

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_network_rules",
        "resourceName": terraLib.get_resource_name(standalone, sName),
        "searchKey": sprintf("azurerm_storage_account_network_rules[%s].default_action", [sName]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "default_action must be 'Deny'",
        "keyActualValue": "default_action is 'Allow' (public)",
        "resourceTags": terraLib.get_resource_tags(standalone),
    }
}

# Surface 2 (standalone): any ip_rule present
WizPolicy[result] {
    document := input.document[i]
    standalone := document.resource.azurerm_storage_account_network_rules[sName]

    ip := standalone.ip_rules[idx]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_network_rules",
        "resourceName": terraLib.get_resource_name(standalone, sName),
        "searchKey": sprintf("azurerm_storage_account_network_rules[%s].ip_rules[%d]", [sName, idx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "ip_rules must be empty",
        "keyActualValue": sprintf("ip_rules[%d] is '%v' (no IP rules permitted)", [idx, ip]),
        "resourceTags": terraLib.get_resource_tags(standalone),
    }
}

# Surface 3 (absence): no inline network_rules and no associated standalone
# resource -> firewall unconfigured -> defaults to Allow (public)
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    not terraLib.validKey(resource, "network_rules")
    not tf_has_associated_network_rules(document, resource, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "storage account must restrict network access (network_rules with default_action 'Deny', no IP rules)",
        "keyActualValue": "no network_rules configured (firewall defaults to Allow / public)",
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
