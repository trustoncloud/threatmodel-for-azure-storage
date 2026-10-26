# Azure Storage Customised CCRs for Wiz

36 Wiz custom configuration rules covering 21 Azure Storage assurance controls
from the TrustOnCloud Azure Storage ThreatModel. Each rule checks your live
Azure estate (Cloud matcher), your Terraform code before deployment
(Terraform matcher), or both. Every rule is test-validated, with property
paths verified against real Wiz payloads, the Azure Storage REST API
specification, and the `azurerm` Terraform provider documentation.

These rules are gap-fillers: each covers an assurance control that Wiz's
built-in CCR library does not address, or addresses only partly. Severities
follow the ThreatModel weighted priority.

---

## Rule naming: two control IDs per rule

Most rule folders carry two control IDs, for example
`Storage.C38_C40_universal`:

- The **first ID** is the paired Directive control. The Terraform matcher
  implements it: it verifies your IaC declares the safeguard before
  deployment.
- The **second ID** is the Assurance control. The cloud matcher verifies it:
  it checks the safeguard is live on the deployed resource.

One rule therefore covers a pre-deploy and a post-deploy control as a single
enforcement intent. A rule with only a cloud matcher keeps one ID
(`Storage.C89_universal`). Each rule's description names its IDs, the mapping
CSV carries a "Paired Control" column, and the `controlId` / `pairedControlId`
tags let you filter in the Wiz console by either ID.

---

## What is in this delivery

21 controls, delivered as 36 rule folders (one per control per mode).

| Rule | Severity | What it flags |
|---|---|---|
| Storage.C38_C40 | Critical | Private endpoint connections that are unauthorized or not approved; storage private endpoints without an authorized private DNS zone |
| Storage.C43_C45 | High | Firewalls that allow by default, or admit unauthorized IP ranges |
| Storage.C108_C109 | High | Accounts without a CanNotDelete or ReadOnly management lock |
| Storage.C33_C146 | High | Blob containers without a version-level or time-based immutability policy |
| Storage.C27_C28 | Medium | Accounts that allow Shared Key without a SAS expiration policy, or with one that is too long or only logs |
| Storage.C61_C65 | Medium | Accounts encrypted with an unauthorized customer-managed key |
| Storage.C149_C81 | Medium | Accounts that allow Shared Key or do not default to Microsoft Entra ID |
| Storage.C89 | Medium | Accounts that allow Shared Key without a key expiration policy, with one that is too long, or with an access key older than it |
| Storage.C95_C97 | Medium | CORS rules with untrusted origins, methods, headers, or excessive max age |
| Storage.C99_C102 | Medium | File services allowing legacy SMB 2.1 |
| Storage.C104_C105 | Medium | Accounts without Defender for Storage malware scanning on upload |
| Storage.C121_C123 | Medium | File services allowing weak SMB Kerberos or channel encryption |
| Storage.C133_C134 | Medium | Accounts of an unauthorized kind (for example general-purpose v1) |
| Storage.C151_C152 | Medium | Object replication to unauthorized destination accounts |
| Storage.C159_C160 | Medium | Data Lake Storage accounts that allow Shared Key, bypassing their access control lists |
| Storage.C162_C163 | Medium | SFTP with local users outside the authorized accounts, and local users allowed to sign in with a password |
| Storage.C168_C169 | Medium | Virtual network rules admitting unauthorized subnets |
| Storage.C171_C172 | Medium | Network rule bypasses for unauthorized services |
| Storage.C23_C24 | Low | Hierarchical namespace (Data Lake Storage) enabled outside the authorized accounts |
| Storage.C156_C157 | Low | Stored access policies on file shares and tables with unauthorized identifiers or permissions |
| Storage.C76_C78 | Informational | Accounts holding data, including geo-redundant copies, outside the authorized regions |

## Coverage breakdown

| Axis | Count |
|---|---|
| Controls | 21 |
| Rule folders (control x mode) | 36 |
| Rules with a cloud matcher | 17 controls (31 folders) |
| Rules with a Terraform matcher | 20 controls (35 folders) |
| Terraform-only rules | 4 controls (no Wiz runtime surface for their settings) |
| Cloud-only rules | 1 control (no Terraform argument for its setting) |
| Cloud OPA tests passing | 159 of 159 |
| Terraform fixture checks passing | 70 of 70 |

Modes shipped per control:

| Modes | Rules |
|---|---|
| allowlist, denylist, universal | Storage.C76_C78, C99_C102, C121_C123 |
| allowlist, universal | Storage.C23_C24, C38_C40, C43_C45, C149_C81, C95_C97, C108_C109, C33_C146, C159_C160, C162_C163 |
| universal | Storage.C27_C28, C89, C104_C105 |
| allowlist | Storage.C61_C65, C133_C134, C151_C152, C156_C157, C168_C169, C171_C172 |

- **allowlist**: flag any resource whose value is not in your authorized set.
- **denylist**: flag any resource whose value is in your forbidden set.
- **universal**: enforce the secure state on every resource (no exceptions).

Enable one mode per control matching your policy posture. See "Select one
mode per control" below.

| Wiz native type | Rules |
|---|---|
| `Microsoft.Storage/storageAccounts` | Storage.C23_C24, C27_C28, C38_C40, C43_C45, C61_C65, C76_C78, C149_C81, C89, C95_C97, C99_C102, C121_C123, C133_C134, C159_C160, C162_C163, C168_C169, C171_C172 |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | Storage.C33_C146 |

| Terraform resource | Rules |
|---|---|
| `azurerm_storage_account` | C24, C28, C45, C65, C78, C81, C97, C102, C105, C109, C123, C134, C160, C163, C169, C172 |
| `azurerm_storage_account_network_rules` | C45, C169, C172 (standalone firewall form) |
| `azurerm_storage_account_customer_managed_key` | C65 (standalone key form) |
| `azurerm_private_endpoint`, `azurerm_private_dns_zone` | C40 |
| `azurerm_security_center_storage_defender`, `azurerm_security_center_subscription_pricing` | C105 |
| `azurerm_management_lock` | C109 |
| `azurerm_storage_container`, `azurerm_storage_container_immutability_policy` | C146 |
| `azurerm_storage_object_replication` | C152 |
| `azurerm_storage_share`, `azurerm_storage_table` | C157 |
| `azurerm_storage_account_local_user` | C163 |

Terraform matchers cover both declaration forms wherever azurerm offers them:
the account's inline `network_rules` and `customer_managed_key` blocks AND
the standalone `azurerm_storage_account_network_rules` and
`azurerm_storage_account_customer_managed_key` resources.

---

## Package layout

```
azure-storage/
├── Cloud_Configuration_Rules/          The deployable rules (36 folders)
│   └── Storage.<parent>_<assurance>_<mode>/
│       ├── cloud/<rule>.rego           Cloud matcher (runtime)
│       ├── terraform/<rule>.rego       Terraform matcher (IaC)
│       ├── terraform/remediation.md    How to fix the Terraform finding
│       └── metadata/
│           ├── metadata.json           Name, severity, native types, tags
│           ├── description.md
│           └── remediation.md          How to fix the live resource
├── terraform_test_samples/             Sample .tf for self-validation,
│   └── Storage.<parent>_<assurance>/   keyed to match the rule folders
│       └── test_<mode>_{pass,fail}.tf
├── main.tf                             Wiz Terraform module (reads Cloud_Configuration_Rules/)
├── providers.tf                        Wiz provider + auth instructions
├── versions.tf
├── Azure Storage Controls and Wiz Mapping.csv   Control-to-rule mapping incl. paired controls
└── README.md                           This document
```

---

## Versioning

Versions are repo-wide rather than per service, and follow a semver-lite scheme:

- A minor bump, `v0.X.0`, means a new service.
- A patch bump, `v0.X.Y`, means a change to a service already published: new
  rules, wider coverage, or fixes to rules already shipped.

Because the version covers the whole repository, a release names the one service
it updates and leaves every other package unchanged. A package downloaded from a
GitHub release carries its service and version in its filename.

---

## Deploying to Wiz

The rules deploy through the Wiz Terraform custom-CCR module, which reads
`Cloud_Configuration_Rules/` and creates each rule in your tenant.

### 1. Create a Wiz service account

In Wiz: Settings -> Access Management -> Service Accounts. Use type
"Custom Integration (GraphQL API)". Tick all permission boxes under the
"Cloud Configuration Rule" and "Cloud Configuration" sections.

### 2. Set credentials

```bash
export WIZ_URL="https://api.<host>.app.wiz.io/graphql"   # Tenant Info -> API Endpoint URL
export WIZ_CLIENT_ID=<your_wiz_client_id>
export WIZ_CLIENT_SECRET=<your_wiz_client_secret>
```

### 3. Apply

```bash
terraform init
terraform plan      # review what will be created
terraform apply
```

`terraform destroy` removes the rules cleanly if you want to back them out.

---

## Before you apply

### Select one mode per control

Each control ships every mode it supports, and the modes overlap. By default
the universal mode is the active one (enabled), giving you a secure baseline
with no configuration. If you prefer the tailored allowlist or denylist mode
for a control, set its authorized values (see below), enable that mode, and
disable the control's universal rule so the two do not both score. To drop a
mode entirely, delete its rule folder before `terraform apply`.

### Replace placeholder allowlist values

Allowlist and denylist rules carry placeholder values under a
`--- Configuration ---` comment block at the top of each `.rego` file. Set
your organization's values in BOTH the cloud and terraform matcher of the
same rule, and keep them in sync.

| Rule | Set this |
|---|---|
| Storage.C23_C24 | Accounts authorized for the hierarchical namespace |
| Storage.C38_C40 | Authorized private endpoints (cloud) and private DNS zones (terraform) |
| Storage.C43_C45 | Authorized firewall IP ranges |
| Storage.C61_C65 | Authorized customer-managed key URLs (versionless) |
| Storage.C76_C78 | Authorized, forbidden or required regions; list both regions of each geo-redundant pair |
| Storage.C149_C81 | Accounts required to use Microsoft Entra ID only |
| Storage.C95_C97 | Trusted CORS origins, methods, headers and max age |
| Storage.C99_C102, C121_C123 | Accounts authorized for SMB 2.1, required SMB encryption values, or forbidden methods |
| Storage.C108_C109 | Accounts required to carry a lock, and the accepted lock levels |
| Storage.C33_C146 | Containers required to be immutable |
| Storage.C133_C134 | Authorized account kinds |
| Storage.C151_C152 | Authorized replication destination accounts |
| Storage.C156_C157 | Authorized stored access policy identifiers and permission letters |
| Storage.C159_C160 | Data Lake Storage accounts allowed to keep Shared Key |
| Storage.C162_C163 | Accounts authorized for SFTP with local users |
| Storage.C168_C169 | Authorized subnet resource IDs |
| Storage.C171_C172 | Authorized network rule bypasses |

The universal rules for C27_C28 and C89 carry thresholds rather than
placeholders: a 1-day SAS maximum with Block, and a 90-day key expiration
period. Adjust them to your policy before enabling.

### Enablement posture

- **Universal-mode rules ship enabled.** They enforce a fixed secure state,
  carry no placeholders, and produce real findings on the first scan.
- **Allowlist and denylist rules ship disabled.** They depend on your
  environment-specific values and stay dormant until you set those values and
  enable them. This avoids a first-scan flood of placeholder-driven findings.

Every rule has `function_as_control: true`, so an enabled rule scores your
posture. To enable an allowlist or denylist rule after configuring it, toggle
it in the Wiz UI, or set `"enabled": true` in that rule's
`metadata/metadata.json` and re-run `terraform apply`.

### Notes on specific rules

- **Terraform-only rules (C104_C105, C108_C109, C151_C152, C156_C157)**:
  Defender for Storage settings, resource locks, object replication policies
  and stored access policies are separate Azure resources that the storage
  account payload does not carry, so the Terraform matcher is the enforcement
  point and there are no runtime findings. A lock, Defender resource or
  immutability policy must be declared in the same `.tf` file as the
  resource it protects to be linked to it.
- **Storage.C89** has no Terraform matcher: azurerm has no argument for the
  account key expiration policy, and key age is not configuration.
- **Storage.C27_C28** checks the account's SAS expiration policy. SAS tokens
  are signed by clients and never stored, so tokens already issued are not
  visible to any scan; rotate the account keys to revoke them.
- **Storage.C162_C163** flags local users only together with SFTP: local
  users sign in over SFTP alone, and Azure turns them on by default on new
  accounts.
- **Storage.C121_C123 (universal)** requires that ONLY the strong SMB values
  are allowed. A file service with no explicit SMB settings keeps Azure's
  defaults, which allow every option, and is flagged.
- **Storage.C76_C78** checks the geo-redundant secondary region as well as
  the primary location in its allowlist and denylist modes.
- **Storage.C38_C40**: the cloud rule checks each connection's approval
  state, which has no author-time equivalent; the Terraform rule checks the
  endpoint's private DNS integration instead. Organizations using custom DNS
  rather than `private_dns_zone_group` will see Terraform findings.

### Upgrading from an earlier deployment

This release changes several rules. Re-apply any allowlist values you had
customized, and note the following:

- **Storage.C27_C28** now checks the SAS expiration policy, following the
  ThreatModel's revised control. Its Shared Key check is part of
  Storage.C149_C81. The allowlist mode is removed and the rule is renamed, so
  findings history on the old rule does not carry over.
- **Storage.C108_C109** no longer has a cloud matcher.
- **Storage.C121_C123** severity rises from Low to Medium, following the
  ThreatModel.

---

## Self-verification

`terraform_test_samples/` contains pass and fail Terraform samples for every
rule with a Terraform matcher, in folders named to match the rule folders.
Upload a `_fail.tf` sample through your Wiz IaC scan (CLI or CI integration)
and confirm the corresponding rule produces a finding; the `_pass.tf` sample
should scan clean. Allowlist samples align with the shipped placeholder
values, so validate them before replacing the placeholders (or update the
samples to your values).

---

## Cloud and Terraform: two surfaces, one rule

Each rule enforces its control pair at two points:

- The **Cloud matcher** scans deployed storage accounts (and containers for
  Storage.C33_C146) during a Wiz cloud scan, against the Azure Resource
  Manager shape.
- The **Terraform matcher** scans `.tf` at build time, before resources
  exist, against the `azurerm` provider shape.

The two surfaces use different field names and shapes for the same setting
(for example ARM `allowSharedKeyAccess` versus Terraform
`shared_access_key_enabled`, and a comma-separated bypass string versus a
Terraform list). Both are kept semantically aligned. Keep their allowlist
values in sync when you customize.

---

## Authoritative references

Property paths in each rule were verified against:

- The Azure Storage resource provider REST API specification
  (`Microsoft.Storage`) and live Wiz payloads for
  `Microsoft.Storage/storageAccounts` and its blob containers.
- The `azurerm` Terraform provider documentation, releases 4.81.0 and 5.10.0:
  - [`azurerm_storage_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
  - [`azurerm_storage_account_network_rules`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules)
  - [`azurerm_storage_account_customer_managed_key`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key)
  - [`azurerm_storage_account_local_user`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_local_user)
  - [`azurerm_private_endpoint`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint)
  - [`azurerm_security_center_storage_defender`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_storage_defender)
  - [`azurerm_management_lock`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock)
  - [`azurerm_storage_container_immutability_policy`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container_immutability_policy)
  - [`azurerm_storage_object_replication`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_object_replication)
  - [`azurerm_storage_share`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share)
  - [`azurerm_storage_table`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table)

---

## Support

For questions on rule logic, allowlist values, or coverage extensions,
contact the TrustOnCloud delivery team. These rules extend the TrustOnCloud
ThreatModel and OverWatch deliverables for Azure Storage.
