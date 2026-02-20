package wiz

# --- Logic ---

default result := "pass"

has_shared_key_config {
    input.properties.allowSharedKeyAccess != null
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_shared_key_config
} else := "fail" {
    input.properties.allowSharedKeyAccess == true
}

# --- Metadata ---

actual_value := val {
    has_shared_key_config
    val := input.properties.allowSharedKeyAccess
} else := "undefined"

currentConfiguration := sprintf("'allowSharedKeyAccess' is set to '%v' for account '%v'", [actual_value, input.name])

expectedConfiguration := "Shared Key access (SAS) must be disabled for all storage accounts to enforce Entra ID authentication."