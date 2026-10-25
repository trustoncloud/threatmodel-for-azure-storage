package wiz

# --- Configuration ---
required_kerberos := "AES-256"
required_channel := "AES-256-GCM"

# --- Logic ---
default result := "pass"

# SMB protocol settings live under the file-service object Wiz aggregates
# onto the storage account, as ";"-separated strings. An absent value means
# Azure's default, which allows every option including the weak ones.
smb_settings := val {
    val := input.AccountStorageServicesFileServiceProperties.properties.protocolSettings.smb
    is_object(val)
}

kerberos := object.get(smb_settings, "kerberosTicketEncryption", "")
channel := object.get(smb_settings, "channelEncryption", "")

other_values(setting, required) := {v |
    v := split(setting, ";")[_]
    v != ""
    v != required
}

is_compliant {
    is_string(kerberos)
    is_string(channel)
    kerberos != ""
    channel != ""
    count(other_values(kerberos, required_kerberos)) == 0
    count(other_values(channel, required_channel)) == 0
}

result := "skip" {
    not smb_settings
} else := "fail" {
    not is_compliant
}

# --- Metadata ---
shown(v) := "Azure default (all options)" {
    v == ""
} else := v

currentConfiguration := sprintf("Kerberos: '%v', Channel: '%v'", [shown(kerberos), shown(channel)])

expectedConfiguration := sprintf("File shares allow only '%v' Kerberos and '%v' channel encryption.", [required_kerberos, required_channel])
