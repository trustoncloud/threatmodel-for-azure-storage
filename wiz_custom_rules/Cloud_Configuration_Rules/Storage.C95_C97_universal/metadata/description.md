# Description

Verify only authorized CORS trusted origins and corresponding settings are configured (e.g., by using a custom Azure Policy on {"Microsoft.Storage/storageAccounts/blobServices/cors.allowedOrigins[*]": ["https://myapp.contoso.com"]} in Audit mode).

This rule covers two paired controls: the Terraform matcher implements Storage.C95 (Directive); the cloud matcher verifies Storage.C97 (Assurance).
