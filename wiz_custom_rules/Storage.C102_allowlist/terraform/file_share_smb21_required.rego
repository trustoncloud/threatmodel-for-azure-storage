package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
allowed_smb21_accounts := {"legacy-app-storage", "migration-temp-share"}

# --- Logic ---
# share_properties.smb.versions is a set of strings in TF (cloud is a
# semicolon-delimited string). Fire when SMB2.1 is present on an account that
# is not authorized for it. Absence of the versions set means SMB2.1 is not
# enabled, so no finding.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]

    sp := terraLib.getValueArrayOrObject(resource.share_properties)
    smb := terraLib.getValueArrayOrObject(sp.smb)
    smb.versions[vidx] == "SMB2.1"
    not allowed_smb21_accounts[resource.name]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].share_properties.smb.versions[%d]", [name, vidx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("SMB2.1 is only permitted for authorized accounts: %v", [allowed_smb21_accounts]),
        "keyActualValue": sprintf("SMB2.1 is enabled on unauthorized account '%v'", [resource.name]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
