# Description

Verify only required storage accounts have the hierarchical namespace (HNS) option enabled (e.g., by using a custom Azure Policy on {"isHnsEnabled": "true"} in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C23 (Directive); the cloud matcher verifies Storage.C24 (Assurance).
