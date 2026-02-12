## 1. Purpose of this PR
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] ♻️ Refactor (no functional changes, no API changes)
- [ ] ⚙️ Build / Configuration change

## 2. Scope
- Cloud / Service: `gcp/bigquery` (example)
- Control ID(s): `Bigquery.C123` (example)
- Variant(s): `universal` / `allowlist` / `denylist`

## 3. Description

## 4. Related Issue (Leave blank if not applicable)
Closes #

## 5. Testing (OPA)
- [ ] I used the repo-bundled OPA (`.\opa.exe` version 0.5.8)
- [ ] I ran tests for the changed control/variant(s)

```powershell
# Example (update to your control/variant)
.\opa.exe test .\gcp\bigquery\controls\Bigquery.C123\universal -v
```

## 6. Checklist
- [ ] I have performed a self-review
- [ ] I added or updated tests (`*_test.rego`) as needed
- [ ] If I ran a folder sweep, I used `.\utils\CCRPackageRename.ps1` to avoid package collisions
- [ ] Package header is `package wiz` for Wiz compatibility in committed Rego
- [ ] Mapping CSV updated if control metadata or mappings changed
