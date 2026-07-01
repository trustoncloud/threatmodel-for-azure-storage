package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Data Lake (HNS-enabled) account names authorized to retain Shared Key
# access (e.g. legacy migrations). All other HNS accounts must disable it.
authorized_legacy_datalakes := {
    "legacy-hadoop-migration",
    "temp-ingest-lake",
}

# --- Helpers ---
is_true(v) { v == true } else { v == "true" }
is_false(v) { v == false } else { v == "false" }

shared_key_explicitly_disabled(resource) {
    terraLib.validKey(resource, "shared_access_key_enabled")
    is_false(resource.shared_access_key_enabled)
}

# --- Logic ---
# Scope is Data Lake Gen2 accounts (is_hns_enabled = true). HNS defaults to
# false, so non-HNS accounts are out of scope (no finding). A Data Lake
# account must have shared_access_key_enabled explicitly false; if it is true
# or omitted (defaults to true), ACL integrity is not enforced. Authorized
# legacy accounts are exempt.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    is_true(resource.is_hns_enabled)
    not authorized_legacy_datalakes[resource.name]
    not shared_key_explicitly_disabled(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].shared_access_key_enabled", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("HNS-enabled accounts must set shared_access_key_enabled=false unless authorized: %v", [authorized_legacy_datalakes]),
        "keyActualValue": sprintf("account '%v' has HNS enabled but Shared Key access is not disabled", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
