package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
authorized_subnet_ids := {
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet"
}

# --- Helpers ---
# The subnet list; null is the same as omitting the argument.
tf_subnet_list(v) := [] {
    v == null
} else := [] {
    v == "${null}"
} else := terraLib.getArray(v)

# Literal subnet IDs that are not authorized, compared in full without regard
# to case. No ID is built from a guessed subscription or resource group.
tf_unauthorized_subnet(ids) := {id |
    id := tf_subnet_list(ids)[_]
    not tocm_tf_unresolved(id)
    not tocm_azure_id_allowed(id, authorized_subnet_ids)
}

# Subnet values this source scan cannot resolve: a reference or a variable.
tf_unresolved_subnet(ids) := {id |
    id := tf_subnet_list(ids)[_]
    tocm_tf_unresolved(id)
}

tf_unverified_text := "subnet authorization cannot be verified from this Terraform source"

# --- Logic ---
# Finding: inline network_rules on the account name an unauthorized subnet.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "network_rules")
    rules := terraLib.getValueArrayOrObject(resource.network_rules)
    id := tf_unauthorized_subnet(object.get(rules, "virtual_network_subnet_ids", []))[_]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].network_rules.virtual_network_subnet_ids", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "every subnet in virtual_network_subnet_ids is authorized",
        "keyActualValue": sprintf("subnet %v is not authorized", [id]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: a subnet value this source scan cannot resolve, so its authorization
# cannot be verified.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "network_rules")
    rules := terraLib.getValueArrayOrObject(resource.network_rules)
    id := tf_unresolved_subnet(object.get(rules, "virtual_network_subnet_ids", []))[_]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].network_rules.virtual_network_subnet_ids", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "every subnet in virtual_network_subnet_ids is authorized",
        "keyActualValue": sprintf("subnet '%v': %v", [id, tf_unverified_text]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Finding: a standalone azurerm_storage_account_network_rules names an
# unauthorized subnet.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account_network_rules[name]
    id := tf_unauthorized_subnet(object.get(resource, "virtual_network_subnet_ids", []))[_]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_network_rules",
        "resourceName": name,
        "searchKey": sprintf("azurerm_storage_account_network_rules[%s].virtual_network_subnet_ids", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "every subnet in virtual_network_subnet_ids is authorized",
        "keyActualValue": sprintf("subnet %v is not authorized", [id]),
        "resourceTags": {},
    }
}

# Finding: a subnet value this source scan cannot resolve, so its authorization
# cannot be verified.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account_network_rules[name]
    id := tf_unresolved_subnet(object.get(resource, "virtual_network_subnet_ids", []))[_]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account_network_rules",
        "resourceName": name,
        "searchKey": sprintf("azurerm_storage_account_network_rules[%s].virtual_network_subnet_ids", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "every subnet in virtual_network_subnet_ids is authorized",
        "keyActualValue": sprintf("subnet '%v': %v", [id, tf_unverified_text]),
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
