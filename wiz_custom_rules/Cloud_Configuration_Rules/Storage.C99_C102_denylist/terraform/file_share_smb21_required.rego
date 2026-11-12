package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
forbidden_versions := {"SMB2.1"}

# File share protocols that must not be used ("SMB" or "NFS").
forbidden_share_protocols := {"NFS"}

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
# Fire when a forbidden SMB version is allowed: listed in versions, or allowed
# by Azure's default when versions is omitted or empty. Fire on a file share
# that uses a forbidden protocol.

# Forbidden version listed explicitly
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    not tf_versions_unresolved(resource)
    ver := tf_configured_versions(resource)[_]
    forbidden_versions[ver]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("SMB versions must not include any forbidden version: %v", [forbidden_versions]),
        "keyActualValue": sprintf("forbidden SMB version '%v' is enabled%s", [ver, tf_kind_note(resource)]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# versions omitted or empty: the Azure default allows a forbidden version
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    not tf_versions_unresolved(resource)
    count(tf_configured_versions(resource)) == 0
    ver := tf_azure_default_smb_versions[_]
    forbidden_versions[ver]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s]", [name]),
        "issueType": "MissingAttribute",
        "keyExpectedValue": sprintf("share_properties.smb.versions lists no forbidden version: %v", [forbidden_versions]),
        "keyActualValue": sprintf("share_properties.smb.versions is not set, so Azure's default allows forbidden version '%v'%s", [ver, tf_kind_note(resource)]),
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
        "keyExpectedValue": sprintf("SMB versions must not include any forbidden version: %v", [forbidden_versions]),
        "keyActualValue": "share_properties.smb.versions is not resolved by this source scan",
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# File share with a forbidden protocol, or a protocol the source scan cannot resolve
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
        "keyExpectedValue": sprintf("enabled_protocol is not one of %v", [forbidden_share_protocols]),
        "keyActualValue": tf_share_protocol_text(protocol),
        "resourceTags": {},
    }
}

tf_share_protocol_flagged(protocol) {
    forbidden_share_protocols[protocol]
}

tf_share_protocol_flagged(protocol) {
    tocm_tf_unresolved(protocol)
}

tf_share_protocol_text(protocol) := "enabled_protocol is not resolved by this source scan" {
    tocm_tf_unresolved(protocol)
} else := sprintf("enabled_protocol is '%v' (forbidden)", [protocol])

# --- Matching helpers ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
