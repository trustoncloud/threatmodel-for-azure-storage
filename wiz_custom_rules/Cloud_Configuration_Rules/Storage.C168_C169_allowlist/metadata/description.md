# Description

Verify each storage account uses only authorized virtual network rules (e.g., by using Azure built-in policy "Storage accounts should restrict network access using virtual network rules" in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C168 (Directive); the cloud matcher verifies Storage.C169 (Assurance).
