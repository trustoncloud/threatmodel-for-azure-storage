package wiz

# --- Logic ---
default result := "pass"

# SMB protocol settings live under the file-service object Wiz aggregates
# onto the storage account.
smb_versions_string := val {
    val := input.AccountStorageServicesFileServiceProperties.properties.protocolSettings.smb.versions
}

has_smb21 {
    parts := split(smb_versions_string, ";")
    parts[_] == "SMB2.1"
}

result := "skip" {
    not smb_versions_string
} else := "fail" {
    has_smb21
}

# --- Metadata ---
currentConfiguration := sprintf("SMB versions: '%v'", [smb_versions_string])
expectedConfiguration := "SMB 2.1 is globally forbidden; all shares must use SMB 3.0 or higher."