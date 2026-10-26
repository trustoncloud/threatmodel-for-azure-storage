# Description

Verify local user functionality for SFTP is enabled only where local users, their permissions, and authentication methods are authorized (e.g., by using a custom Azure Policy to detect storage accounts where "Microsoft.Storage/storageAccounts/localUsersEnabled" = true and "Microsoft.Storage/storageAccounts/isSftpEnabled" = true, in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C162 (Directive); the cloud matcher verifies Storage.C163 (Assurance).
