package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Regions where storage accounts are explicitly forbidden (lowercase).
forbidden_regions := {"brazilsouth", "centralindia", "southafricanorth"}

# --- Logic ---
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    terraLib.validKey(resource, "location")
    forbidden_regions[lower(resource.location)]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].location", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("location must not be one of the forbidden regions: %v", [forbidden_regions]),
        "keyActualValue": sprintf("location is '%v' (forbidden)", [resource.location]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
