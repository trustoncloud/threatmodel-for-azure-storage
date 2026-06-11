# Description

Verify Azure Data Lake Storage Gen2 functionality is enabled only where Access Control Lists (ACLs) on containers are authorized (e.g., by using a custom Azure Policy to detect storage accounts where "Microsoft.Storage/storageAccounts/isHnsEnabled" = true and "Microsoft.Storage/storageAccounts/allowSharedKeyAccess" = false, in Audit mode).
