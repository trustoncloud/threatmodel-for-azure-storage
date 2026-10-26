# Description

Verify replication policies and their destination storage accounts are authorized (e.g., by using a custom Azure Policy on "Microsoft.Storage/storageAccounts/objectReplicationPolicies[*].destinationAccount" and "Microsoft.Storage/storageAccounts/objectReplicationPolicies[*].rules[*].sourceContainer" in Audit mode).

This rule implements Storage.C151 (Directive) through its Terraform matcher; Storage.C152 is the paired Assurance control (no runtime scan surface).

Because it has no cloud matcher it carries no target native type, so it will not appear while a Native Type filter is applied and it reports no cloud findings. Filter on 'Created by equals User' or 'Target Platform equals Terraform' to see it.
