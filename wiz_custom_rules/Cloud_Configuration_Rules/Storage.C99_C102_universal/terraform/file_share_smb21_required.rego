package wiz

import data.generic.terraform as terraLib

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

# --- Logic ---
# Universal: SMB2.1 is not allowed on any account with a file service, and no
# file share uses NFS. An omitted versions list keeps Azure's default, which
# allows SMB2.1.

# SMB2.1 listed explicitly
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    not tf_versions_unresolved(resource)
    tf_configured_versions(resource)["SMB2.1"]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "share_properties.smb.versions lists SMB3.0 or later only",
        "keyActualValue": sprintf("SMB2.1 is enabled%s", [tf_kind_note(resource)]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# versions omitted or empty: the Azure default allows SMB2.1
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    not tf_versions_unresolved(resource)
    count(tf_configured_versions(resource)) == 0

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "MissingAttribute",
        "keyExpectedValue": "share_properties.smb.versions lists SMB3.0 or later only",
        "keyActualValue": sprintf("share_properties.smb.versions is not set, so Azure's default allows %v%s", [concat(", ", sort(tf_azure_default_smb_versions)), tf_kind_note(resource)]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# versions not resolved by the source scan
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    tf_versions_unresolved(resource)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "share_properties.smb.versions lists SMB3.0 or later only",
        "keyActualValue": "share_properties.smb.versions is not resolved by this source scan",
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# NFS file share, or a protocol the source scan cannot resolve
WizPolicy[result] {
    document := input.document[i]
    share := document.resource.azurerm_storage_share[name]
    protocol := object.get(share, "enabled_protocol", "SMB")
    tf_share_protocol_flagged(protocol)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_share",
        "resourceName": terraLib.get_resource_name(share, name),
        "searchKey": sprintf("azurerm_storage_share[%s].enabled_protocol", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "enabled_protocol is SMB",
        "keyActualValue": tf_share_protocol_text(protocol),
        "resourceTags": {},
    }
}

tf_share_protocol_flagged(protocol) {
    protocol == "NFS"
}

tf_share_protocol_flagged(protocol) {
    tocm_tf_unresolved(protocol)
}

tf_share_protocol_text(protocol) := "enabled_protocol is not resolved by this source scan" {
    tocm_tf_unresolved(protocol)
} else := sprintf("enabled_protocol is '%v'", [protocol])

# --- Matching helpers ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
