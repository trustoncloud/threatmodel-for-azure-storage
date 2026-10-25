package wiz

import data.generic.terraform as terraLib

# --- Logic ---
# Universal: SMB2.1 is globally forbidden; all shares must use SMB 3.0+.
# Fire when SMB2.1 is present in share_properties.smb.versions.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    smb := terraLib.getValueArrayOrObject(sp.smb)
    smb.versions[vidx] == "SMB2.1"

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions[%d]", [name, vidx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "SMB2.1 must not be enabled (use SMB 3.0 or higher)",
        "keyActualValue": "SMB2.1 is enabled",
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
