# Description

Verify only authorized customer-managed keys are configured for storage accounts (e.g., by using the built-in Azure Policy "Storage accounts should use customer-managed key for encryption" in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C61 (Directive); the cloud matcher verifies Storage.C65 (Assurance).
