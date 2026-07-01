package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# --- Logic ---
# Universal: HNS (Data Lake) must be disabled for every storage account.
# is_hns_enabled defaults to false, so absence is compliant (no absence
# block). Fire only when HNS is explicitly enabled.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    is_true(resource.is_hns_enabled)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].is_hns_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "is_hns_enabled must be false (HNS/Data Lake disabled) for all storage accounts",
        "keyActualValue": sprintf("is_hns_enabled is true for account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
