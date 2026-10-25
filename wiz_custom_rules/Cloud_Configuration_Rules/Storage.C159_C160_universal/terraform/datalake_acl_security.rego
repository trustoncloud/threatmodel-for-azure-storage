package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }
is_false(v) { v == false } else { v == "false" }

shared_key_explicitly_disabled(resource) {
    terraLib.validKey(resource, "shared_access_key_enabled")
    is_false(resource.shared_access_key_enabled)
}

# --- Logic ---
# Universal: every Data Lake Gen2 account (is_hns_enabled = true) must have
# shared_access_key_enabled explicitly false. HNS defaults to false, so
# non-HNS accounts are out of scope. shared_access_key_enabled defaults to
# true, so "not explicitly disabled" (true or omitted) is a violation.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    is_true(resource.is_hns_enabled)
    not shared_key_explicitly_disabled(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].shared_access_key_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "HNS-enabled (Data Lake Gen2) accounts must set shared_access_key_enabled=false",
        "keyActualValue": sprintf("account '%v' has HNS enabled but Shared Key access is not disabled", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
