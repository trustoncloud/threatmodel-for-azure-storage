package wiz

# --- Configuration ---
allowed_smb21_accounts := {"legacy-app-storage", "migration-temp-share"}

# --- Logic ---
default result := "pass"

smb_versions_string := val {
    val := input.properties.protocolSettings.smb.versions
}

has_smb21 {
    parts := split(smb_versions_string, ";")
    parts[_] == "SMB2.1"
}

is_allowed_account {
    allowed_smb21_accounts[input.name]
}

result := "skip" {
    not input.properties
} else := "skip" {
    not smb_versions_string
} else := "pass" {
    is_allowed_account # Authorized accounts can have any version
} else := "fail" {
    has_smb21 # Unauthorized accounts fail if SMB2.1 is present
}

# --- Metadata ---
currentConfiguration := sprintf("SMB versions: '%v' for account '%v'", [smb_versions_string, input.name])
expectedConfiguration := "SMB 2.1 is only permitted for authorized legacy accounts."