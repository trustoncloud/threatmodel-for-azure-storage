package wiz

# --- Configuration ---
# Required accounts for strict enforcement
required_secure_shares := {"finance-share", "hr-share"}

# Using the exact strings from Microsoft documentation
required_kerberos := "AES-256"
required_channel := "AES-256-GCM"

# --- Logic ---

default result := "pass"

smb_settings := val {
    val := input.properties.protocolSettings.smb
}

has_smb_settings {
    smb_settings != null
}

is_required_share {
    required_secure_shares[input.name]
}

# Logic to check if the required value is present in the delimited string
# Traditional syntax uses 'split' and index matching
is_compliant {
    # Check Kerberos
    kerberos_parts := split(smb_settings.kerberosTicketEncryption, ";")
    kerberos_parts[_] == required_kerberos
    
    # Check Channel Encryption
    channel_parts := split(smb_settings.channelEncryption, ";")
    channel_parts[_] == required_channel
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_smb_settings
} else := "pass" {
    not is_required_share
} else := "fail" {
    is_required_share
    not is_compliant
}

# --- Metadata ---

current_kerberos := val {
    val := smb_settings.kerberosTicketEncryption
} else := "undefined"

current_channel := val {
    val := smb_settings.channelEncryption
} else := "undefined"

currentConfiguration := sprintf("kerberosTicketEncryption='%v', channelEncryption='%v' for account '%v'", [current_kerberos, current_channel, input.name])

expectedConfiguration := sprintf("Required file shares must include '%v' for Kerberos and '%v' for Channel Encryption in their settings.", [required_kerberos, required_channel])