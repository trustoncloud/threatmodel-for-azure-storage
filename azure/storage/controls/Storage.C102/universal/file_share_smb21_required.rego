package wiz

# --- Logic ---
default result := "pass"

smb_versions_string := val {
    val := input.properties.protocolSettings.smb.versions
}

has_smb21 {
    parts := split(smb_versions_string, ";")
    parts[_] == "SMB2.1"
}

result := "skip" {
    not input.properties
} else := "skip" {
    not smb_versions_string
} else := "fail" {
    has_smb21
}

# --- Metadata ---
currentConfiguration := sprintf("SMB versions: '%v'", [smb_versions_string])
expectedConfiguration := "SMB 2.1 is globally forbidden; all shares must use SMB 3.0 or higher."