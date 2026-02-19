package wiz

# --- Logic ---
default result := "pass"

is_version_immutability_enabled {
    input.properties.immutableStorageWithVersioning.enabled == true
}

result := "skip" {
    not input.name
} else := "fail" {
    not is_version_immutability_enabled
}

# --- Metadata ---
current_state := val {
    is_version_immutability_enabled
    val := "Enabled"
} else := "Disabled"

currentConfiguration := sprintf("Version-level immutability is '%v' for container '%v'", [current_state, input.name])
expectedConfiguration := "All storage containers must have 'immutableStorageWithVersioning' enabled (Universal mode)."