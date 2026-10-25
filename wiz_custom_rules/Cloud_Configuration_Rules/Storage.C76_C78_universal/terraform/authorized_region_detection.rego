package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# The single authorized region for the entire environment (lowercase).
required_region := "eastus"

# --- Logic ---
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    terraLib.validKey(resource, "location")
    lower(resource.location) != required_region

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].location", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("location must be '%v' for all storage accounts", [required_region]),
        "keyActualValue": sprintf("location is '%v'", [resource.location]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
