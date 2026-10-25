# Description

Verify each storage account uses only authorized network ACL bypass configurations (e.g., by using Azure built-in policy "Storage Accounts should restrict network access through network ACL bypass configuration only" in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C171 (Directive); the cloud matcher verifies Storage.C172 (Assurance).
