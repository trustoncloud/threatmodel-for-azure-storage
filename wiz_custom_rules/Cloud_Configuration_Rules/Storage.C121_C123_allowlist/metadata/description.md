# Description

Verify required file shares' security protocol settings are configured (e.g., by using a custom Azure Policy on {"Microsoft.Storage/storageAccounts/fileServices/protocolSettings.smb": {"kerberosTicketEncryption":"AES256","channelEncryption":"Required"}} in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C121 (Directive); the cloud matcher verifies Storage.C123 (Assurance).
