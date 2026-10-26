# Description

Verify Shared Key authorization is disabled (and optionally that OAuth is the default) for authorized storage accounts that host authorized blobs, file shares, queues, tables, and DFS (e.g., by using a custom Azure Policy to require "Microsoft.Storage/storageAccounts/allowSharedKeyAccess" = false and, optionally, "Microsoft.Storage/storageAccounts/defaultToOAuthAuthentication" = true in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C149 (Directive); the cloud matcher verifies Storage.C81 (Assurance).
