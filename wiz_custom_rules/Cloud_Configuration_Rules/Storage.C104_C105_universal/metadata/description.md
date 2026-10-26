# Description

Verify required storage accounts use malware scanning for uploaded blob content (e.g., by using Microsoft Defender for Storage malware scanning).

This rule implements Storage.C104 (Directive) through its Terraform matcher; Storage.C105 is the paired Assurance control (no runtime scan surface).

Because it has no cloud matcher it carries no target native type, so it will not appear while a Native Type filter is applied and it reports no cloud findings. Filter on 'Created by equals User' or 'Target Platform equals Terraform' to see it.
