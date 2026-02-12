package wiz

# --- Configuration ---
# Specific accounts identified as hosting sensitive/authorized data
required_secure_accounts := {"finance-archive", "audit-logs", "prod-customer-data"}

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
currentConfiguration := sprintf("Account '%v' security: SharedKey=%v, OAuthDefault=%v", [
    input.name, 
    input.properties.allowSharedKeyAccess, 
    input.properties.defaultToOAuthAuthentication
])
expectedConfiguration := "High-value storage accounts must strictly disable Shared Keys and enforce OAuth defaults."