# Description

Verify only the authorized storage account region is set for redundancy (e.g., by using a custom Azure Policy with {"location": ["eastus","westeurope"]} in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C76 (Directive); the cloud matcher verifies Storage.C78 (Assurance).
