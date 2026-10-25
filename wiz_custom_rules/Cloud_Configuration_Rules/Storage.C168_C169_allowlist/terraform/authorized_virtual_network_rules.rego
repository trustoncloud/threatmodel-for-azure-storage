package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
authorized_subnet_ids := {
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet"
}

# --- Helpers ---
tf_authorized_lower := {lower(s) | s := authorized_subnet_ids[_]}

# A reference to another resource (${...}) resolves only at apply time, so
# only literal subnet IDs are judged.
tf_unauthorized_subnet(ids) := {id |
    id := terraLib.getArray(ids)[_]
    is_string(id)
    not contains(id, "${")
    not tf_authorized_lower[lower(id)]
}

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
