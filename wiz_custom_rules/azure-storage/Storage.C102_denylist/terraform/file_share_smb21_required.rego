package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
forbidden_versions := {"SMB2.1"}

# --- Logic ---
# Fire when any forbidden SMB version is present in share_properties.smb.versions.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    smb := terraLib.getValueArrayOrObject(sp.smb)
    ver := smb.versions[vidx]
    forbidden_versions[ver]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions[%d]", [name, vidx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("SMB versions must not include any forbidden version: %v", [forbidden_versions]),
        "keyActualValue": sprintf("forbidden SMB version '%v' is enabled", [ver]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
