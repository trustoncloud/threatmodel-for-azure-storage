package wiz

# --- Configuration ---
required_containers := {"examplefinancearchive", "exampleauditlogs"}

# --- Logic ---
default result := "pass"

is_required_container {
    required_containers[input.name]
}

# Either form protects the container's blobs: version-level immutability, or a
# container-level time-based policy (hasImmutabilityPolicy).
is_immutable {
    input.properties.immutableStorageWithVersioning.enabled == true
}

is_immutable {
    input.properties.hasImmutabilityPolicy == true
}

result := "skip" {
    not input.name
} else := "pass" {
    not is_required_container
} else := "fail" {
    is_required_container
    not is_immutable
}

# --- Metadata ---
current_state := val {
    is_immutable
    val := "Enabled"
} else := "Disabled"

currentConfiguration := sprintf("Immutability policy is '%v' for container '%v'", [current_state, input.name])
expectedConfiguration := "Required containers must have a version-level or time-based immutability policy."