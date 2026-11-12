package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
required_kerberos := "AES-256"
required_channel := "AES-256-GCM"

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

tf_actual_text(resource, attr, others) := sprintf("%v is not resolved by this source scan", [attr]) {
    tf_attr_unresolved(resource, attr)
} else := sprintf("%v is not set, so Azure's default allows %v%s", [attr, others, tf_kind_note(resource)]) {
    count(tf_configured(resource, attr)) == 0
} else := sprintf("%v also allows %v%s", [attr, others, tf_kind_note(resource)])

# --- Logic ---
# Universal: on every account with a file service, Kerberos and channel
# encryption allow only the configured values. An omitted list keeps Azure's
# default, which allows every option.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_has_file_service(resource)
    check := [
        ["kerberos_ticket_encryption_type", required_kerberos],
        ["channel_encryption_type", required_channel],
    ][_]
    others := {v | v := tf_effective(resource, check[0])[_]; v != check[1]}
    tf_flagged(resource, check[0], others)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.%s", [name, check[0]]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("%v is [\"%v\"]", [check[0], check[1]]),
        "keyActualValue": tf_actual_text(resource, check[0], others),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

tf_flagged(resource, attr, _) {
    tf_attr_unresolved(resource, attr)
}

tf_flagged(resource, attr, others) {
    not tf_attr_unresolved(resource, attr)
    count(others) > 0
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
