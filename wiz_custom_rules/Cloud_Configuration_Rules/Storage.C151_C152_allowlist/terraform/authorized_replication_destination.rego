package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Names of the storage accounts that object replication may copy blobs to.
# Add your own alongside; matching ignores case.
authorized_replication_destination_accounts := {"examplereplicadest"}

# --- Helpers ---
authorized_lower := {lower(a) | a := authorized_replication_destination_accounts[_]}

# The destination account's name, from a literal resource ID
# (.../storageAccounts/<name>) or a reference to an azurerm_storage_account
# declared in the same file. Other references resolve only at apply time.
destination_name(document, ref) := name {
    is_string(ref)
    not contains(ref, "${")
    parts := split(trim_suffix(ref, "/"), "/")
    name := lower(parts[count(parts) - 1])
} else := name {
    is_string(ref)
    account := document.resource.azurerm_storage_account[local]
    contains(ref, sprintf("azurerm_storage_account.%s.", [local]))
    is_string(account.name)
    name := lower(account.name)
}

# --- Logic ---
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_object_replication[name]
    dest := destination_name(document, object.get(resource, "destination_storage_account_id", ""))
    not authorized_lower[dest]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_object_replication",
        "resourceName": name,
        "searchKey": sprintf("azurerm_storage_object_replication[%s].destination_storage_account_id", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("destination account is one of %v", [authorized_replication_destination_accounts]),
        "keyActualValue": sprintf("destination account is %v", [dest]),
        "resourceTags": {},
    }
}
