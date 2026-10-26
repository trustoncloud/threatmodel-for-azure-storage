# Description

Verify required storage accounts use Azure resource locks (e.g., by using built-in Azure Policy "Resource locks should be applied" in Audit mode).

This rule implements Storage.C108 (Directive) through its Terraform matcher; Storage.C109 is the paired Assurance control (no runtime scan surface).

Because it has no cloud matcher it carries no target native type, so it will not appear while a Native Type filter is applied and it reports no cloud findings. Filter on 'Created by equals User' or 'Target Platform equals Terraform' to see it.
