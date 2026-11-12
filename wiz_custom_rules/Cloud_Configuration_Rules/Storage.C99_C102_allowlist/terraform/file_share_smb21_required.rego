package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
allowed_smb21_accounts := {"examplelegacyapp", "migration-temp-share"}

# --- Helpers ---
# SMB versions Azure allows when versions is omitted or empty.
tf_azure_default_smb_versions := {"SMB2.1", "SMB3.0", "SMB3.1.1"}

# Account kinds without a file service; an omitted account_kind is StorageV2.
tf_no_file_service_kinds := {"BlockBlobStorage", "BlobStorage"}

tf_has_file_service(resource) {
    not tf_no_file_service_kinds[object.get(resource, "account_kind", "StorageV2")]
}

tf_kind_note(resource) := " (account_kind is not resolved by this source scan, so the account is judged as one with file shares)" {
    tocm_tf_unresolved(object.get(resource, "account_kind", ""))
} else := ""

tf_account_allowed(account_name) {
    is_string(account_name)
    lower(account_name) == lower(allowed_smb21_accounts[_])
}

tf_smb(resource) := smb {
    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    smb := terraLib.getValueArrayOrObject(sp.smb)
    is_object(smb)
} else := {}

tf_versions_unresolved(resource) {
    tocm_tf_unresolved(object.get(tf_smb(resource), "versions", ""))
}

tf_versions_unresolved(resource) {
    tocm_tf_unresolved(object.get(tf_smb(resource), "versions", [])[_])
}

tf_configured_versions(resource) := {v | v := object.get(tf_smb(resource), "versions", [])[_]; is_string(v)} {
    is_array(object.get(tf_smb(resource), "versions", ""))
} else := set()

tf_allows_smb21(resource) {
    tf_versions_unresolved(resource)
}

tf_allows_smb21(resource) {
    tf_configured_versions(resource)["SMB2.1"]
}

tf_allows_smb21(resource) {
    count(tf_configured_versions(resource)) == 0
}

tf_smb21_text(resource) := "share_properties.smb.versions is not resolved by this source scan" {
    tf_versions_unresolved(resource)
} else := sprintf("share_properties.smb.versions is not set, so Azure's default allows SMB2.1%s", [tf_kind_note(resource)]) {
    count(tf_configured_versions(resource)) == 0
} else := sprintf("SMB2.1 is enabled%s", [tf_kind_note(resource)])

# The account a share belongs to: the literal name of an azurerm_storage_account
# referenced in the same document, or the account segment of a literal ARM ID.
tf_share_account_name(document, share) := account {
    ref := object.get(share, "storage_account_id", "")
    found := regex.find_all_string_submatch_n(`^\$\{\s*azurerm_storage_account\.([A-Za-z0-9_-]+)(?:\[[^\]]*\])?\.id\s*\}$`, ref, 1)
    count(found) == 1
    account := document.resource.azurerm_storage_account[found[0][1]].name
    is_string(account)
    not tocm_tf_unresolved(account)
}

tf_share_account_name(document, share) := account {
    parts := split(tocm_azure_id_norm(object.get(share, "storage_account_id", "")), "/")
    count(parts) == 9
    parts[5] == "providers"
    parts[6] == "microsoft.storage"
    parts[7] == "storageaccounts"
    account := parts[8]
}

tf_share_allowed(document, share) {
    tf_account_allowed(tf_share_account_name(document, share))
}

tf_share_account_text(document, share) := sprintf("an NFS share on account '%v', which is not authorized", [tf_share_account_name(document, share)]) {
    tf_share_account_name(document, share)
} else := "an NFS share whose storage_account_id is not resolved by this source scan"

# --- Logic ---
# SMB2.1 and NFS file shares are allowed only on authorized accounts. An
# omitted versions list keeps Azure's default, which allows SMB2.1.

# Account that allows SMB2.1 and is not authorized
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    not tf_account_allowed(resource.name)
    tf_allows_smb21(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("SMB2.1 is only permitted for authorized accounts: %v", [allowed_smb21_accounts]),
        "keyActualValue": sprintf("account '%v' is not authorized: %s", [resource.name, tf_smb21_text(resource)]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# NFS share on an account that is not authorized or not resolved
WizPolicy[result] {
    document := input.document[i]
    share := document.resource.azurerm_storage_share[name]
    protocol := object.get(share, "enabled_protocol", "SMB")
    tf_share_may_be_nfs(protocol)
    not tf_share_allowed(document, share)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_share",
        "resourceName": terraLib.get_resource_name(share, name),
        "searchKey": sprintf("azurerm_storage_share[%s].enabled_protocol", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("NFS file shares only on authorized accounts: %v", [allowed_smb21_accounts]),
        "keyActualValue": tf_share_text(document, share, protocol),
        "resourceTags": {},
    }
}

tf_share_may_be_nfs(protocol) {
    protocol == "NFS"
}

tf_share_may_be_nfs(protocol) {
    tocm_tf_unresolved(protocol)
}

tf_share_text(document, share, protocol) := "enabled_protocol is not resolved by this source scan" {
    tocm_tf_unresolved(protocol)
} else := tf_share_account_text(document, share)

# --- Matching helpers ---
# --- toc-match begin: azureid v1 ---
# Azure resource IDs compare case-insensitively, segment by segment.
tocm_azure_id_norm(id) := n {
    is_string(id)
    n := lower(trim_suffix(trim_space(id), "/"))
    startswith(n, "/subscriptions/")
    not contains(n, "//")
}

tocm_azure_id_equal(a, b) {
    tocm_azure_id_norm(a) == tocm_azure_id_norm(b)
}

tocm_azure_id_allowed(id, allowed) {
    tocm_azure_id_equal(id, allowed[_])
}
# --- toc-match end: azureid v1 ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
