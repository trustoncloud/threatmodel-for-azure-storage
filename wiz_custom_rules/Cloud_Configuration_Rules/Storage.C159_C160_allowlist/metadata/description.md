# Description

Verify Azure Data Lake Storage Gen2 functionality is enabled only where Access Control Lists (ACLs) on containers are authorized (e.g., by using a custom Azure Policy to detect storage accounts where "Microsoft.Storage/storageAccounts/isHnsEnabled" = true and "Microsoft.Storage/storageAccounts/allowSharedKeyAccess" = true, in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C159 (Directive); the cloud matcher verifies Storage.C160 (Assurance).
