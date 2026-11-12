package wiz

# --- Configuration ---
# Also require Microsoft Entra ID (OAuth) as the default authorization in the
# portal. Shared Key must be off whatever this is set to.
require_oauth_default := true

# --- Logic ---
default result := "pass"

oauth_default_ok {
    not require_oauth_default
}

oauth_default_ok {
    input.properties.defaultToOAuthAuthentication == true
}

# Shared Key is off, and OAuth is the portal default when required.
is_compliant {
    input.properties.allowSharedKeyAccess == false
    oauth_default_ok
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
expectedConfiguration := sprintf("Every storage account disables Shared Key; OAuth as the portal default required: %v", [require_oauth_default])