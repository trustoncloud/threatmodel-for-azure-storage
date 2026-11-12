package wiz

# --- Configuration ---
allowed_smb21_accounts := {"examplelegacyapp", "migration-temp-share"}

# --- Logic ---
default result := "pass"

# SMB versions Azure allows when the setting is absent or empty.
azure_default_smb_versions := {"SMB2.1", "SMB3.0", "SMB3.1.1"}

# SMB protocol settings live under the file-service object on the storage
# account; the object is absent or null on account kinds without file shares.
file_service := fs {
    fs := input.AccountStorageServicesFileServiceProperties
    is_object(fs)
}

smb_settings := s {
    s := file_service.properties.protocolSettings.smb
    is_object(s)
} else := {}

versions_setting := v {
    v := smb_settings.versions
    is_string(v)
} else := ""

configured_versions := {v | v := split(versions_setting, ";")[_]; v != ""}

uses_azure_default {
    count(configured_versions) == 0
}

effective_versions := configured_versions {
    not uses_azure_default
} else := azure_default_smb_versions

result := "skip" {
    not file_service
} else := "pass" {
    allowed_smb21_accounts[input.name]
} else := "fail" {
    effective_versions["SMB2.1"]
}

# --- Metadata ---
shown_versions := sprintf("Azure default (all versions: %v)", [concat(";", sort(azure_default_smb_versions))]) {
    uses_azure_default
} else := versions_setting

currentConfiguration := sprintf("SMB versions: '%v' for account '%v'", [shown_versions, input.name])
expectedConfiguration := "SMB 2.1 is allowed only on authorized accounts; other accounts list SMB 3.0 or later in the SMB versions setting, because an empty setting allows SMB 2.1. NFS is set per file share and is not part of the storage account data, so this check does not cover it."
