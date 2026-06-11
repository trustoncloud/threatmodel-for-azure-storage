# Azure Storage Custom Configuration Rules for Wiz

13 custom Wiz rules covering high-priority Azure Storage assurance controls
from the TrustOnCloud Azure Storage ThreatModel. Each control ships with two
matchers: a Cloud matcher that scans deployed resources at runtime, and a
Terraform matcher that scans infrastructure-as-code before deployment.
Severities follow the ThreatModel weighted priority.

Each rule covers an assurance control that the built-in Wiz rule library does
not address. The package deploys to your Wiz tenant with a single
`terraform apply` and removes just as cleanly with `terraform destroy`.

---

## What is in this release

13 controls, delivered as 29 rules (one per control per mode).

| Control | Severity | What it flags |
|---|---|---|
| Storage.C40 | Critical | Storage private endpoints not integrated with an authorized private DNS zone |
| Storage.C45 | High | Accounts with an open network firewall (default action Allow) or unauthorized IP rules |
| Storage.C109 | High | Accounts without a CanNotDelete or ReadOnly management lock |
| Storage.C146 | High | Blob containers without an immutability policy |
| Storage.C28 | Medium | Accounts that allow Shared Key (SAS) access |
| Storage.C81 | Medium | Accounts that do not disable Shared Key and default to Entra ID (OAuth) authentication |
| Storage.C97 | Medium | CORS rules with untrusted origins, methods, headers, or excessive max-age (blob, queue, share) |
| Storage.C160 | Medium | Data Lake Gen2 accounts that do not enforce Shared-Key-disabled for ACL integrity |
| Storage.C163 | Medium | Accounts with SFTP and local users enabled outside the authorized set |
| Storage.C24 | Low | Accounts with Hierarchical Namespace (Data Lake Gen2) enabled outside the authorized set |
| Storage.C102 | Low | File shares permitting legacy SMB 2.1 |
| Storage.C123 | Low | File shares with weak SMB Kerberos or channel encryption |
| Storage.C78 | Informational | Accounts deployed outside the authorized regions |

Every rule carries both matchers and was validated before release: 117
automated tests across the Cloud matchers, and 58 Terraform fixtures
(compliant and violating pairs) across the Terraform matchers, with property
paths verified against the Azure ARM resource schema and the `azurerm`
Terraform provider documentation.

---

## Rule modes

Most controls ship in more than one mode, so you can pick the enforcement
style that matches your policy:

- **allowlist**: flag any resource whose value is outside your authorized set.
- **denylist**: flag any resource whose value is in your forbidden set.
- **universal**: require the secure state on every resource, with no
  exceptions.

| Modes shipped | Controls |
|---|---|
| allowlist, universal | C24, C28, C40, C45, C81, C97, C109, C146, C160, C163 |
| allowlist, denylist, universal | C78, C102, C123 |

Each rule targets the relevant resource type:

| Wiz native type | Controls |
|---|---|
| `Microsoft.Storage/storageAccounts` | all except C146 |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | C146 |

| Terraform resource | Controls |
|---|---|
| `azurerm_storage_account` | C24, C28, C45, C78, C81, C97, C102, C123, C160, C163 |
| `azurerm_storage_account_network_rules` | C45 (standalone firewall form) |
| `azurerm_private_endpoint`, `azurerm_private_dns_zone` | C40 |
| `azurerm_management_lock` | C109 |
| `azurerm_storage_container`, `azurerm_storage_container_immutability_policy` | C146 |

---

## Package layout

```
├── wiz_custom_rules/                       The deployable rules (29 folders, one per control+mode)
│   └── Storage.C<n>_<mode>/
│       ├── cloud/<rule>.rego               Cloud matcher (runtime)
│       ├── terraform/<rule>.rego           Terraform matcher (IaC)
│       └── metadata/                       Name, severity, native types, tags, description, remediation
└── wiz_deployment/                         Everything needed to deploy and test the rules
    ├── README.md                           This guide
    ├── main.tf  providers.tf  versions.tf  Terraform configuration that deploys the rules
    ├── azure-storage.manifest.json         Catalog of all 13 controls in one JSON
    ├── Azure Storage Controls and Wiz Mapping.csv
    └── terraform_test_samples/             Sample .tf files for testing the Terraform matchers
        └── Storage.C<n>/test_<mode>_{pass,fail}.tf
```

Keep `wiz_custom_rules/` to rule folders only: the Wiz Terraform module treats
every entry in that folder as a rule.

The manifest (`azure-storage.manifest.json`) is the quick reference: every
control's id, name, description, severity, modes, matchers, and target types
in a single file.

Each deployed rule is tagged for filtering in Wiz: `controlId` (matching the
ThreatModel control), `mode`, `objective`, `csp`, and `service`.

---

## Deploying to Wiz

### 1. Create a Wiz service account

In Wiz: Settings, then Access Management, then Service Accounts. Use the type
"Custom Integration (GraphQL API)" and grant all permissions under the
"Cloud Configuration Rule" and "Cloud Configuration" sections.

### 2. Set credentials

The Wiz provider reads credentials from environment variables. They last only
for the current terminal session, so set them again in each new session.

```bash
export WIZ_URL="https://api.<host>.app.wiz.io/graphql"   # Tenant Info -> API Endpoint URL
export WIZ_CLIENT_ID=<your_wiz_client_id>
export WIZ_CLIENT_SECRET=<your_wiz_client_secret>
```

PowerShell equivalent: `$env:WIZ_URL = "..."` and so on. For unattended use,
source the values from your secrets manager rather than typing them inline.

### 3. Apply from the wiz_deployment folder

```bash
cd wiz_deployment
terraform init
terraform plan      # review: 29 rules to create
terraform apply
```

`terraform destroy` removes all 29 rules.

---

## Before you apply

### Enablement: what is on by default

The package ships with a deliberate split:

- **Universal-mode rules are enabled** (13 rules). They enforce a fixed secure
  state and need no configuration, so they produce accurate findings on the
  first scan.
- **Allowlist and denylist rules are disabled** (16 rules). They depend on
  values specific to your environment, so they stay dormant until you set
  those values and switch them on. This prevents a first-scan flood of
  false positives from unconfigured rules.

Enabled rules also function as controls, so they contribute to your posture
score. Disabled rules ship with `enabled` and `function_as_control` both set
to false (Wiz requires the two to change together). To activate a rule after
configuring it, set both fields to `true` in that rule's
`metadata/metadata.json` and re-run `terraform apply`, or switch both toggles
in the Wiz console.

### Configure the allowlist and denylist values

These rules contain placeholder values under a `--- Configuration ---` block
at the top of each `.rego` file, in both the cloud and terraform matcher.
Replace them with your organization's values, and keep the two matchers of
the same control in sync.

| Control | Set this |
|---|---|
| C78 | Authorized (or forbidden) Azure regions |
| C24, C28, C160, C163 | Authorized storage account names |
| C45 | Authorized firewall IP ranges (CIDR supported) |
| C97 | Trusted CORS origins, methods, headers, max-age cap |
| C102, C123 | Authorized SMB legacy or encryption values |
| C40 | Authorized private DNS zone names |
| C109 | Required lock level (CanNotDelete or ReadOnly) |

### Run one mode per control

The modes of a control overlap, so enable only the one that matches your
policy. The universal mode gives you a secure baseline with no configuration;
if you prefer the tailored allowlist or denylist mode, configure and enable
it, then disable that control's universal rule so both do not score the same
resource. To exclude a mode from deployment entirely, delete its
`Storage.C<n>_<mode>/` folder before running `terraform apply`.

---

## Testing the rules in your tenant

Both matchers can be exercised directly in the Wiz rule editor:

- **Terraform matchers**: open a rule, choose Upload IaC File, and upload a
  sample from `wiz_deployment/terraform_test_samples/`. Every
  `test_<mode>_fail.tf` returns a fail result (the Wiz test output shows only
  the first failing resource, even when a sample contains several); every
  `test_<mode>_pass.tf` returns pass. The samples double as working examples
  of compliant and non-compliant Terraform.
- **Cloud matchers**: use Run Test in the rule editor against a resource JSON,
  or simply review the findings of the first scheduled scan.

---

## One control, two enforcement points

- The **Cloud matcher** evaluates deployed storage accounts (and containers
  for C146) during Wiz cloud scans, against the Azure ARM resource shape.
- The **Terraform matcher** evaluates `.tf` code at build time, before any
  resource exists, against the `azurerm` provider shape.

The two surfaces name the same setting differently (for example ARM
`allowSharedKeyAccess` versus Terraform `shared_access_key_enabled`), and the
rules keep the semantics aligned. When you customize allowlist values, update
both matchers of the control.

---

## References

Property paths in each rule were verified against:

- The Azure ARM `Microsoft.Storage/storageAccounts` resource schema, including
  the per-service Blob, File, Queue, and Table service properties.
- The `azurerm` Terraform provider documentation:
  - [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
  - [`azurerm_storage_account_network_rules`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules)
  - [`azurerm_private_endpoint`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
  - [`azurerm_private_dns_zone`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)
  - [`azurerm_management_lock`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock)
  - [`azurerm_storage_container_immutability_policy`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container_immutability_policy)

---

## Support

For questions on rule logic, configuration values, or coverage extensions,
please contact the TrustOnCloud team.
