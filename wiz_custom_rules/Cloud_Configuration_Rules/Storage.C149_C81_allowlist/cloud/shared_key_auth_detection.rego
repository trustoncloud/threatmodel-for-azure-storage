package wiz

# --- Configuration ---
# Specific accounts identified as hosting sensitive/authorized data
required_secure_accounts := {"examplefinancearchive", "exampleauditlogs", "examplecustomerdata"}

# Also require Microsoft Entra ID (OAuth) as the default authorization in the
# portal. Shared Key must be off whatever this is set to.
require_oauth_default := true

# --- Logic ---
default result := "pass"

is_required_account {
    required_secure_accounts[input.name]
}

oauth_default_ok {
    not require_oauth_default
}

oauth_default_ok {
    input.properties.defaultToOAuthAuthentication == true
}

is_compliant {
    input.properties.allowSharedKeyAccess == false
    oauth_default_ok
}

# Logic Chain
result := "skip" {
    not input.name
} else := "pass" {
    not is_required_account
} else := "fail" {
    is_required_account
    not is_compliant
}

# --- Metadata ---
# Absent fields take Azure's defaults: Shared Key on, OAuth not the default.
currentConfiguration := sprintf("Account '%v' security: SharedKey=%v, OAuthDefault=%v", [
    input.name,
    object.get(object.get(input, "properties", {}), "allowSharedKeyAccess", true),
    object.get(object.get(input, "properties", {}), "defaultToOAuthAuthentication", false)
])
expectedConfiguration := sprintf("Required accounts disable Shared Key; OAuth as the portal default required: %v", [require_oauth_default])