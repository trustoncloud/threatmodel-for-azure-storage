package wiz

# --- Configuration ---
required_containers := {"finance-archive", "audit-logs"}

# --- Logic ---
default result := "pass"

is_required_container {
    required_containers[input.name]
}

is_version_immutability_enabled {
    input.properties.immutableStorageWithVersioning.enabled == true
}

# Fix: Ensure the variable name matches the definition above
result := "skip" {
    not input.name
} else := "pass" {
    not is_required_container
} else := "fail" {
    is_required_container           # Fixed variable name here
    not is_version_immutability_enabled
}

# --- Metadata ---
current_state := val {
    is_version_immutability_enabled
    val := "Enabled"
} else := "Disabled"

currentConfiguration := sprintf("Version-level immutability is '%v' for container '%v'", [current_state, input.name])
expectedConfiguration := "Authorized containers must have 'immutableStorageWithVersioning' enabled."