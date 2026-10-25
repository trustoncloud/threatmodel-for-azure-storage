# Description

Verify stored access policies and their permissions are authorized for each container, file share, queue, and table.

This rule implements Storage.C156 (Directive) through its Terraform matcher; Storage.C157 is the paired Assurance control (no runtime scan surface).

Because it has no cloud matcher it carries no target native type, so it will not appear while a Native Type filter is applied and it reports no cloud findings. Filter on 'Created by equals User' or 'Target Platform equals Terraform' to see it.
