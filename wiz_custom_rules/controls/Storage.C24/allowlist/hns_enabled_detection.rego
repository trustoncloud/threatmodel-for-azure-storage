package wiz

# --- Configuration ---
# Add the names of storage accounts that ARE allowed to have HNS enabled
allowed_hns_accounts := {"data_lake_prod", "analytics_storage_01"}

# --- Logic ---

default result := "pass"

# Helper to check if the property exists
has_hns_config {
    input.properties.isHnsEnabled != null
}

# Determine if the current account is in the allowlist
is_allowed {
    input.name == allowed_hns_accounts[_]
}

# Logic chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_hns_config
} else := "pass" {
    is_allowed
    input.properties.isHnsEnabled == true
} else := "fail" {
    input.properties.isHnsEnabled == true
}

# --- Metadata ---

actual_value := input.properties.isHnsEnabled {
    has_hns_config
} else := "undefined"

currentConfiguration := sprintf("'isHnsEnabled' is set to '%v' for account '%v'", [actual_value, input.name])

expectedConfiguration := "HNS should be disabled unless the account is in the allowed list."