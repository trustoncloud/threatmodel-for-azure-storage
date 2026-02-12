package wiz

# --- Configuration ---
forbidden_versions := {"SMB2.1"}

# --- Logic ---
default result := "pass"

smb_versions_string := val {
    val := input.properties.protocolSettings.smb.versions
}

violations[msg] {
    parts := split(smb_versions_string, ";")
    version := parts[_]
    forbidden_versions[version]
    msg := sprintf("Forbidden SMB version detected: %v", [version])
}

result := "skip" {
    not input.properties
} else := "skip" {
    not smb_versions_string
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Violations: %v", [violations])
expectedConfiguration := sprintf("The following SMB versions are strictly prohibited: %v", [forbidden_versions])