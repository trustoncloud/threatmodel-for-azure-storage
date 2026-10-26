package wiz

# --- Logic ---
default result := "pass"

# Compliance Check: Shared Key must be FALSE and OAuth Default must be TRUE
is_compliant {
    input.properties.allowSharedKeyAccess == false
    input.properties.defaultToOAuthAuthentication == true
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "fail" {
    not is_compliant
}

# --- Metadata ---
shared_key_status := val {
    val := input.properties.allowSharedKeyAccess
} else := "true (Default)"

oauth_status := val {
    val := input.properties.defaultToOAuthAuthentication
} else := "false (Default)"

currentConfiguration := sprintf("allowSharedKeyAccess='%v', defaultToOAuthAuthentication='%v'", [shared_key_status, oauth_status])
expectedConfiguration := "Every storage account must have Shared Key access disabled (false) and default to OAuth (true)."