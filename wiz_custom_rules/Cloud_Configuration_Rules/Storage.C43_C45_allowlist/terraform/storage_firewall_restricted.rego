package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Public IPs / CIDRs permitted through the storage account firewall.
authorized_ips := {"20.50.100.10/32", "40.70.150.0/24"}

# --- Helpers ---
# True if a standalone azurerm_storage_account_network_rules resource in this
# document is linked to the given account (via storage_account_id).
has_associated_network_rules(document, resource, name) {
    standalone := document.resource.azurerm_storage_account_network_rules[sName]
    terraLib.associatedResources(resource, standalone, name, sName, null, "storage_account_id")
}

# An IP rule is authorized if it exactly matches an allowlist entry, or
# falls within an authorized CIDR range (a host IP inside an approved
# subnet, or a bare IP matching an approved /32).
ip_authorized(ip) {
    authorized_ips[ip]
}

ip_authorized(ip) {
    cidr := authorized_ips[_]
    indexof(cidr, "/") != -1
    net.cidr_contains(cidr, ip)
}

# --- Logic ---
# Firewall can be declared inline (network_rules block) or via the standalone
# azurerm_storage_account_network_rules resource. Scan both. If neither is
# present, the account defaults to public (default_action Allow) and fails.

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

# Surface 1 (inline): unauthorized IP rule
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    nr := terraLib.getValueArrayOrObject(resource.network_rules)
    ip := nr.ip_rules[idx]
    not ip_authorized(ip)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].network_rules.ip_rules[%d]", [name, idx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("network_rules.ip_rules entries must be in the authorized list: %v", [authorized_ips]),
        "keyActualValue": sprintf("network_rules.ip_rules[%d] is '%v' (not authorized)", [idx, ip]),
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

# Surface 2 (standalone): unauthorized IP rule
WizPolicy[result] {
    document := input.document[i]
    standalone := document.resource.azurerm_storage_account_network_rules[sName]

    ip := standalone.ip_rules[idx]
    not ip_authorized(ip)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_network_rules",
        "resourceName": terraLib.get_resource_name(standalone, sName),
        "searchKey": sprintf("azurerm_storage_account_network_rules[%s].ip_rules[%d]", [sName, idx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("ip_rules entries must be in the authorized list: %v", [authorized_ips]),
        "keyActualValue": sprintf("ip_rules[%d] is '%v' (not authorized)", [idx, ip]),
        "resourceTags": terraLib.get_resource_tags(standalone),
    }
}

# Surface 3 (absence): no inline network_rules and no associated standalone
# resource -> firewall unconfigured -> defaults to Allow (public)
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    not terraLib.validKey(resource, "network_rules")
    not has_associated_network_rules(document, resource, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "storage account must restrict network access (network_rules with default_action 'Deny')",
        "keyActualValue": "no network_rules configured (firewall defaults to Allow / public)",
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
