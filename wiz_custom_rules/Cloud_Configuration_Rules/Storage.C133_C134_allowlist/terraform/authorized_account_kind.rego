package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
authorized_account_kinds := {"StorageV2"}

# --- Helpers ---
# account_kind defaults to StorageV2 when omitted.
tf_account_kind(resource) := kind {
    terraLib.validKey(resource, "account_kind")
    kind := resource.account_kind
} else := "StorageV2"

# --- Logic ---
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    kind := tf_account_kind(resource)
    not authorized_account_kinds[kind]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].account_kind", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("account_kind is one of %v", [authorized_account_kinds]),
        "keyActualValue": sprintf("account_kind is %v", [kind]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
