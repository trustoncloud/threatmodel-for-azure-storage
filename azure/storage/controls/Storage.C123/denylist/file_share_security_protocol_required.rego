package wiz

# --- Configuration ---
# Methods the client explicitly wants to ban
forbidden_methods := {"RC4-HMAC", "AES-128-CCM", "AES-128-GCM"}

# --- Logic ---
default result := "pass"

smb_settings := val {
    val := input.properties.protocolSettings.smb
}

has_smb_settings {
    smb_settings != null
}

# Helper to identify violations in the semicolon-delimited strings
violations[msg] {
    # Check Kerberos
    parts := split(smb_settings.kerberosTicketEncryption, ";")
    method := parts[_]
    forbidden_methods[method]
    msg := sprintf("Forbidden Kerberos encryption found: %v", [method])
}

violations[msg] {
    # Check Channel Encryption
    parts := split(smb_settings.channelEncryption, ";")
    method := parts[_]
    forbidden_methods[method]
    msg := sprintf("Forbidden Channel encryption found: %v", [method])
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_smb_settings
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Violations found: %v", [violations])
expectedConfiguration := sprintf("The following encryption methods are strictly forbidden: %v", [forbidden_methods])