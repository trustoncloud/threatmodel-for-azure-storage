package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
has_associated_network_rules(document, resource, name) {
    standalone := document.resource.azurerm_storage_account_network_rules[sName]
    terraLib.associatedResources(resource, standalone, name, sName, null, "storage_account_id")
}

# --- Logic ---
# Universal (private mode): the firewall must have default_action 'Deny' and
# NO ip_rules (access via private endpoints / trusted services only). Scan
# the inline block, the standalone resource, and the absence case.

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

# Surface 1 (inline): any ip_rule present (none allowed in private mode)
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
        "keyExpectedValue": "network_rules.ip_rules must be empty (private mode allows no IP rules)",
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
        "keyExpectedValue": "ip_rules must be empty (private mode allows no IP rules)",
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
    not has_associated_network_rules(document, resource, name)

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
