# Description

Verify storage account firewall rules allow only authorized IPs (e.g., by using built-in Azure Policy "Storage accounts should restrict network access" in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C43 (Directive); the cloud matcher verifies Storage.C45 (Assurance).
