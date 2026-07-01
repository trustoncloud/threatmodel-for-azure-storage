## Intro

Sigma is a portable detection rule format for log and SIEM use, similar in spirit to how YARA describes patterns for files. It lets security teams write one rule in a simple, readable format and then convert or translate it into queries for different SIEMs and log platforms.

It is especially useful for sharing detections across teams and tools without rewriting the logic every time. In practice, Sigma helps analysts express "what to look for" in logs, while the SIEM-specific backend handles how to query that data.

To learn more about Sigma, check their official documentation: https://sigmahq.io

As Sigma is focused on detection rules for logs, the scope is the Detective/Detect controls, as these controls monitor for a specific indicator of compromise (e.g., a logging event with specific parameters).

In this directory you can find the sigma rules and variables for the rules. Variables in Sigma are named placeholders embedded directly in a rule's detection logic, written as `%variable_name%` and resolved at query-generation time through a transformation file. It allows you to write a single rule and during query generation, you can fill up these placeholders with environment-specific values, that match your needs without rewriting the rule logic itself.

## Rule modes

The Sigma rules use the same approach as the Open-source WIZ-CCR we published. Each control can be translated to up to 3 rule modes, depending on how the detection logic is defined or tuned.

**Universal mode:** where the log pattern provides all information needed without any customer-supplied input. It is used when a rule should apply with no exceptions.

**Allowlist mode:** need customer input via variables. The detection works for all the events that are not related to a resource that customer marked as authorized, which can be a storage account, a caller principal, a file-share path or anything else mentioned in our controls. Customer fill up the variable file with their custom values for authorized resources, and during conversion, the query generated check for events related only to resources not listed as authorized.

**Denylist mode:** opposite behavior from the allowlist. It needs customer input via variables, but in this mode the customer provide unauthorized resources as values, setting the scope to specific bad values. Useful when only a small portion of resources are considered a violation, and anything else is acceptable.

Important to note that not every control needs all 3 modes, and in fact very few implement all 3 modes. Some detections are unambiguous enough that only the universal variant makes sense, while others are context-dependent and only the allowlist or denylist variant is practical. The Azure Storage controls currently ship universal and allowlist modes only.

## Rule levels

The [Sigma documentation](https://sigmahq.io/docs/basics/rules.html#metadata-level) defines five level values: critical, high, medium, low and informational.

TrustOnCloud threatmodels use a five-step scale that almost matches Sigma. As of now we are using the following mapping between TrustOnCloud control and Sigma rules:

|TrustOnCloud |	Sigma level |
|---|---|
|Very High	| critical |
|High	| high |
|Medium	| medium |
|Low	| low |
|Very Low |	informational |

## Log sources

The Azure Storage controls currently read from a single log source:

| Log source | What it covers | Controls |
|---|---|---|
| `AzureActivity` | Control-plane (management) operations, available via the Azure Activity Log connector | C101, C179, C180 |

## Variables

This folder holds the **per-customer settings** the Sigma rules read at conversion time, such as "these callers are authorized to read account keys" or "blob moves are normal on these storage accounts". The rules stay generic and reusable, while your environment-specific values live here.

Each variable name carries the **control ID it belongs to** as a suffix, so it's obvious which rule a value affects.

| File | What it contains |
|---|---|
| `customer.azure.storage.example.yml` | Sample Azure Storage profile, with placeholder storage accounts and file-share paths |

### How to use the variables

1 - Edit or copy the variable files, replacing each placeholder with your real storage accounts, caller object IDs, file-share paths, etc. Inline comments explain what each variable controls and which rule uses it.

2 - Run a sigma parser (e.g., [sigma-cli](https://github.com/SigmaHQ/sigma-cli), [RSigma](https://github.com/timescale/rsigma), [PySigma](https://github.com/SigmaHQ/pySigma)) with your variable file

3 - The generated SIEM queries contain your real values, to be used with your playbooks, SIEM, SOC, etc.

## Summary of Azure Storage controls and Sigma rules

| **#** | **Control** | **Control Definition** | **Control Testing** | **Sigma Rule Summary** | **Rule Level** | **Allowlist Mode** | **Denylist Mode** | **Universal Mode** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | C101 | Monitor the creation or update of Azure Files NFS/SMB 2.1 and corresponding settings (e.g., using activity logs on properties.supportsHttpsTrafficOnly scope "supportsHttpsTrafficOnly"). | Modify or create a file share that does not require NFS/SMB 2.1 to use NFS/SMB 2.1; it should be detected. | Detects file-service, file-share, or storage-account write operations that set SMB 2.1, NFS, or supportsHttpsTrafficOnly. The allowlist mode suppresses authorized file-service and storage-account scopes. | Low | Yes | N/A | Yes |
| 2 | C179 | Monitor Azure activity log for configuration operations on blob storage containers (e.g., by using an Azure custom policy on authorization.action where the value is "Microsoft.Storage/storageAccounts/blobServices/containers/clearLegalHold/action", "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies/write", or "Microsoft.Storage/storageAccounts/blobServices/containers/setLegalHold/action" in Audit mode). | Perform a configuration change on a blob storage container; it should be detected. | Detects legal-hold and immutability (WORM) policy changes on blob containers: setting or clearing a legal hold, or writing an immutability policy. | High | N/A | N/A | Yes |
| 3 | C180 | Monitor the Azure activity log for key access operations on storage local users (e.g., by using an Azure custom policy on authorization.action where the value is "Microsoft.Storage/storageAccounts/localUsers/listKeys/action" in Audit mode). | Perform a key access operation on a local storage user; it should be detected. | Detects listing of a storage account's local-user keys, the credentials behind SFTP / NFS local-user access. | Medium | N/A | N/A | Yes |
