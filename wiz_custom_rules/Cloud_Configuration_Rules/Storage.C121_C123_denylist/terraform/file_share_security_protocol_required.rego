package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
forbidden_methods := {"RC4-HMAC", "AES-128-CCM", "AES-128-GCM"}

# --- Logic ---
# Fire when any forbidden encryption method appears in the Kerberos or
# Channel encryption sets.

# Forbidden Kerberos encryption
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    smb := terraLib.getValueArrayOrObject(sp.smb)
    m := smb.kerberos_ticket_encryption_type[_]
    forbidden_methods[m]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.kerberos_ticket_encryption_type", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("kerberos_ticket_encryption_type must not include forbidden methods: %v", [forbidden_methods]),
        "keyActualValue": sprintf("forbidden Kerberos encryption '%v' is configured", [m]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Forbidden Channel encryption
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    smb := terraLib.getValueArrayOrObject(sp.smb)
    m := smb.channel_encryption_type[_]
    forbidden_methods[m]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.channel_encryption_type", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("channel_encryption_type must not include forbidden methods: %v", [forbidden_methods]),
        "keyActualValue": sprintf("forbidden Channel encryption '%v' is configured", [m]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
