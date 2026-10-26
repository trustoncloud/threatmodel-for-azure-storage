# Description

Verify required storage container blobs have immutability policies enabled (e.g., by using the built-in Azure Policy "Immutable blob storage should be enabled" in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C33 (Directive); the cloud matcher verifies Storage.C146 (Assurance).
