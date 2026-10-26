package wiz

# --- Configuration ---
# Specific accounts identified as hosting sensitive/authorized data
required_secure_accounts := {"examplefinancearchive", "exampleauditlogs", "examplecustomerdata"}

# --- Logic ---
default result := "pass"

is_required_account {
    required_secure_accounts[input.name]
}

is_compliant {
    input.properties.allowSharedKeyAccess == false
    input.properties.defaultToOAuthAuthentication == true
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
expectedConfiguration := "High-value storage accounts must strictly disable Shared Keys and enforce OAuth defaults."