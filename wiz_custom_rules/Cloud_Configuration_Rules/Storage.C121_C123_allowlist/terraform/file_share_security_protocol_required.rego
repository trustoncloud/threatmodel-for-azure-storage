package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Storage accounts whose file shares must allow only the configured SMB encryption.
required_secure_shares := {"examplefinanceshare", "examplehrshare"}

# Values as Azure names them.
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

tf_required_account(account_name) {
    is_string(account_name)
    lower(account_name) == lower(required_secure_shares[_])
}

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

tf_actual_text(resource, attr, others) := sprintf("required account '%v': %v is not resolved by this source scan", [resource.name, attr]) {
    tf_attr_unresolved(resource, attr)
} else := sprintf("required account '%v': %v is not set, so Azure's default allows %v%s", [resource.name, attr, others, tf_kind_note(resource)]) {
    count(tf_configured(resource, attr)) == 0
} else := sprintf("required account '%v': %v also allows %v%s", [resource.name, attr, others, tf_kind_note(resource)])

tf_flagged(resource, attr, _) {
    tf_attr_unresolved(resource, attr)
}

tf_flagged(resource, attr, others) {
    not tf_attr_unresolved(resource, attr)
    count(others) > 0
}

# --- Logic ---
# Required accounts allow only the configured Kerberos and channel encryption
# values. An omitted list keeps Azure's default, which allows every option.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    tf_required_account(resource.name)
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

# --- Matching helpers ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
