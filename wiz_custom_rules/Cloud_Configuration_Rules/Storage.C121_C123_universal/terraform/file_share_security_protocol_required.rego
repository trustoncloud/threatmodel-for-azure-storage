package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Keep in sync with the cloud matcher.
required_kerberos := "AES-256"
required_channel := "AES-256-GCM"

# --- Helpers ---
# An omitted list keeps Azure's default, which allows every option.
tf_other_values(smb, attr, required) := others {
    terraLib.validKey(smb, attr)
    others := {v | v := smb[attr][_]; v != required}
} else := {"Azure default (all options)"}

# --- Logic ---
# Universal: where an smb block is declared, Kerberos and channel encryption
# allow only the strong values.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "share_properties")
    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    terraLib.validKey(sp, "smb")
    smb := terraLib.getValueArrayOrObject(sp.smb)
    check := [
        ["kerberos_ticket_encryption_type", required_kerberos],
        ["channel_encryption_type", required_channel],
    ][_]
    others := tf_other_values(smb, check[0], check[1])
    count(others) > 0

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.%s", [name, check[0]]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("%v is [\"%v\"]", [check[0], check[1]]),
        "keyActualValue": sprintf("%v also allows %v", [check[0], others]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
