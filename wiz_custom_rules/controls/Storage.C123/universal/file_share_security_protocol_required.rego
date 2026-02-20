package wiz

# --- Configuration ---
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

is_compliant {
    kerberos_parts := split(smb_settings.kerberosTicketEncryption, ";")
    kerberos_parts[_] == required_kerberos
    
    channel_parts := split(smb_settings.channelEncryption, ";")
    channel_parts[_] == required_channel
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_smb_settings
} else := "fail" {
    not is_compliant
}

# --- Metadata ---
currentConfiguration := sprintf("Kerberos: '%v', Channel: '%v'", [smb_settings.kerberosTicketEncryption, smb_settings.channelEncryption])
expectedConfiguration := sprintf("All file shares must include '%v' (Kerberos) and '%v' (Channel) encryption.", [required_kerberos, required_channel])