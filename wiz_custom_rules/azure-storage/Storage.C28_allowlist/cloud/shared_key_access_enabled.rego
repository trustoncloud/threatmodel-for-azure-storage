package wiz

# --- Configuration ---
allowed_sas_accounts := {"backup_storage_prod", "legacy_app_share"}

# --- Logic ---

default result := "pass"

has_shared_key_config {
    input.properties.allowSharedKeyAccess != null
}

is_allowed {
    allowed_sas_accounts[input.name]
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_shared_key_config
} else := "pass" {
    is_allowed
} else := "fail" {
    input.properties.allowSharedKeyAccess == true
}

# --- Metadata ---

actual_value := val {
    has_shared_key_config
    val := input.properties.allowSharedKeyAccess
} else := "undefined"

currentConfiguration := sprintf("'allowSharedKeyAccess' is set to '%v' for account '%v'", [actual_value, input.name])

expectedConfiguration := "Shared Key access is only permitted for storage accounts explicitly defined in the authorized allowlist."