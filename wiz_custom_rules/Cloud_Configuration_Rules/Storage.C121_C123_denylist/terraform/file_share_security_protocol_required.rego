package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Encryption methods that must not be allowed for Kerberos or channel encryption.
forbidden_methods := {"RC4-HMAC", "AES-128-CCM", "AES-128-GCM"}

# --- Helpers ---
# Values Azure allows when a list is omitted or empty.
tf_azure_default_smb_values := {
    "kerberos_ticket_encryption_type": {"RC4-HMAC", "AES-256"},
    "channel_encryption_type": {"AES-128-CCM", "AES-128-GCM", "AES-256-GCM"},
}

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

tf_attr_unresolved(resource, attr) {
    tocm_tf_unresolved(object.get(tf_smb(resource), attr, ""))
}

tf_attr_unresolved(resource, attr) {
    tocm_tf_unresolved(object.get(tf_smb(resource), attr, [])[_])
}

tf_configured(resource, attr) := {v | v := object.get(tf_smb(resource), attr, [])[_]; is_string(v)} {
    is_array(object.get(tf_smb(resource), attr, ""))
} else := set()

tf_effective(resource, attr) := tf_configured(resource, attr) {
    count(tf_configured(resource, attr)) > 0
} else := tf_azure_default_smb_values[attr]

tf_method_text(resource, attr, m) := sprintf("%v is not set, so Azure's default allows forbidden method '%v'%s", [attr, m, tf_kind_note(resource)]) {
    count(tf_configured(resource, attr)) == 0
} else := sprintf("%v allows forbidden method '%v'%s", [attr, m, tf_kind_note(resource)])

# --- Logic ---
# Fire when a forbidden method is allowed for Kerberos or channel encryption:
# listed explicitly, or allowed by Azure's default when the list is omitted.

# Forbidden method allowed
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    attr := ["kerberos_ticket_encryption_type", "channel_encryption_type"][_]
    not tf_attr_unresolved(resource, attr)
    m := tf_effective(resource, attr)[_]
    forbidden_methods[m]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.%s", [name, attr]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("%v must not include forbidden methods: %v", [attr, forbidden_methods]),
        "keyActualValue": tf_method_text(resource, attr, m),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# List not resolved by the source scan
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    attr := ["kerberos_ticket_encryption_type", "channel_encryption_type"][_]
    tf_attr_unresolved(resource, attr)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.%s", [name, attr]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("%v must not include forbidden methods: %v", [attr, forbidden_methods]),
        "keyActualValue": sprintf("%v is not resolved by this source scan", [attr]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# --- Matching helpers ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
