package wiz

# --- Configuration ---
required_kerberos := "AES-256"
required_channel := "AES-256-GCM"

# --- Logic ---
default result := "pass"

# Values Azure allows when a setting is absent or empty.
azure_default_smb_values := {
    "kerberosTicketEncryption": {"RC4-HMAC", "AES-256"},
    "channelEncryption": {"AES-128-CCM", "AES-128-GCM", "AES-256-GCM"},
}

# SMB protocol settings live under the file-service object on the storage
# account as ";"-separated strings; the object is absent or null on account
# kinds without file shares.
file_service := fs {
    fs := input.AccountStorageServicesFileServiceProperties
    is_object(fs)
}

smb_settings := s {
    s := file_service.properties.protocolSettings.smb
    is_object(s)
} else := {}

setting_text(key) := v {
    v := smb_settings[key]
    is_string(v)
} else := ""

configured(key) := {v | v := split(setting_text(key), ";")[_]; v != ""}

effective(key) := configured(key) {
    count(configured(key)) > 0
} else := azure_default_smb_values[key]

other_values(key, required) := {v | v := effective(key)[_]; v != required}

is_compliant {
    count(other_values("kerberosTicketEncryption", required_kerberos)) == 0
    count(other_values("channelEncryption", required_channel)) == 0
}

result := "skip" {
    not file_service
} else := "fail" {
    not is_compliant
}

# --- Metadata ---
shown(key) := "Azure default (all options)" {
    count(configured(key)) == 0
} else := setting_text(key)

currentConfiguration := sprintf("Kerberos: '%v', Channel: '%v'", [shown("kerberosTicketEncryption"), shown("channelEncryption")])

expectedConfiguration := sprintf("File shares allow only '%v' Kerberos and '%v' channel encryption, as the configured policy; an empty setting allows every supported value.", [required_kerberos, required_channel])
