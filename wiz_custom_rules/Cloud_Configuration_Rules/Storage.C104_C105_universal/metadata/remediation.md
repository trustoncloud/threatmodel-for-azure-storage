# Remediation

Malware scanning on upload is not on for the account in the finding. Turn it on through the Defender for Storage plan:

```bash
az security pricing create --name StorageAccounts --tier Standard --subplan DefenderForStorageV2 --extensions name=OnUploadMalwareScanning isEnabled=True
```

The plan covers every storage account in the subscription and bills per account and per scanned gigabyte; where only some accounts need scanning, enable it on each account from its Microsoft Defender for Cloud page instead. An account-level setting that overrides the subscription must keep scanning on.

## References

- [az security pricing create](https://learn.microsoft.com/en-us/cli/azure/security/pricing?view=azure-cli-latest#az-security-pricing-create)
- [Microsoft Defender for Storage On-upload Malware Scanning - Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/on-upload-malware-scanning)

Checked 2026-10-23 with Azure CLI 2.91.0: command syntax, flags and links.

## Testing Compliance
Upload malware test content to a required storage account; it should be detected.
