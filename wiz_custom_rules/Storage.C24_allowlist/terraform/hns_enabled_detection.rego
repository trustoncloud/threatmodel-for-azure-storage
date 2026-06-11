package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Storage account names (the `name` argument) authorized to have
# Hierarchical Namespace (HNS) enabled.
allowed_hns_accounts := {
    "data_lake_prod",
    "analytics_storage_01",
}

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }

# --- Logic ---
# is_hns_enabled defaults to false, so an account that omits it is not a Data
# Lake and is out of scope (no absence block needed). Fire only when HNS is
# explicitly enabled on an account that is not authorized for it.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    is_true(resource.is_hns_enabled)
    not allowed_hns_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].is_hns_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("is_hns_enabled must be false unless the account is authorized for HNS: %v", [allowed_hns_accounts]),
        "keyActualValue": sprintf("is_hns_enabled is true for unauthorized account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
