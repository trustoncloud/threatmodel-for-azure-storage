# Description

Verify only file shares that require NFS/SMB 2.1 have it enabled (e.g., by using a custom Azure Policy on {"Microsoft.Storage/storageAccounts/fileServices/protocolSettings.smb.protocolVersions[*]": ["SMB2.1"]} in Audit mode).
