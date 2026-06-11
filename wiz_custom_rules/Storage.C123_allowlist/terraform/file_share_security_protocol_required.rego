package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
required_secure_shares := {"finance-share", "hr-share"}
required_kerberos := "AES-256"
required_channel := "AES-256-GCM"

# --- Helpers ---
has_value(arr, v) { arr[_] == v }

# --- Logic ---
# Required shares must include the strong Kerberos and Channel encryption values.
# Evaluated only when an smb block is present.

# Missing required Kerberos encryption
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    required_secure_shares[resource.name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    terraLib.validKey(sp, "smb")
    smb := terraLib.getValueArrayOrObject(sp.smb)
    not has_value(smb.kerberos_ticket_encryption_type, required_kerberos)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.kerberos_ticket_encryption_type", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("kerberos_ticket_encryption_type must include '%v'", [required_kerberos]),
        "keyActualValue": sprintf("required share '%v' does not include Kerberos '%v'", [resource.name, required_kerberos]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Missing required Channel encryption
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    required_secure_shares[resource.name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    terraLib.validKey(sp, "smb")
    smb := terraLib.getValueArrayOrObject(sp.smb)
    not has_value(smb.channel_encryption_type, required_channel)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.channel_encryption_type", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("channel_encryption_type must include '%v'", [required_channel]),
        "keyActualValue": sprintf("required share '%v' does not include Channel '%v'", [resource.name, required_channel]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
