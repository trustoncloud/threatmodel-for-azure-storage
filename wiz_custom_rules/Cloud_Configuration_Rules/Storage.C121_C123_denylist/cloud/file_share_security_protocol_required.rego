package wiz

# --- Configuration ---
# Encryption methods that must not be allowed for Kerberos or channel encryption.
forbidden_methods := {"RC4-HMAC", "AES-128-CCM", "AES-128-GCM"}

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

violations[msg] {
    some key
    azure_default_smb_values[key]
    method := effective(key)[_]
    forbidden_methods[method]
    msg := sprintf("%v allows forbidden method %v", [key, method])
}

result := "skip" {
    not file_service
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
shown(key) := "Azure default (all options)" {
    count(configured(key)) == 0
} else := setting_text(key)

currentConfiguration := sprintf("Kerberos: '%v', Channel: '%v'. Violations: %v", [shown("kerberosTicketEncryption"), shown("channelEncryption"), violations])
expectedConfiguration := sprintf("Kerberos and channel encryption allow none of %v; an empty setting allows every option.", [forbidden_methods])
