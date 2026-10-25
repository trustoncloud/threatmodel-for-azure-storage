# Description

Verify only authorized private endpoints are configured on storage accounts (e.g., by using the built-in Azure Policy "Storage accounts should use Private Link" in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C38 (Directive); the cloud matcher verifies Storage.C40 (Assurance).
