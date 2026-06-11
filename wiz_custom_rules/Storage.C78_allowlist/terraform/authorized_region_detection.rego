package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Authorized Azure regions (lowercase).
allowed_regions := {"eastus", "westeurope", "australiaeast"}

# --- Logic ---
# location is a required argument, so it is always present. Compare
# case-insensitively.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    terraLib.validKey(resource, "location")
    not allowed_regions[lower(resource.location)]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].location", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("location must be one of the authorized regions: %v", [allowed_regions]),
        "keyActualValue": sprintf("location is '%v' (not authorized)", [resource.location]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
