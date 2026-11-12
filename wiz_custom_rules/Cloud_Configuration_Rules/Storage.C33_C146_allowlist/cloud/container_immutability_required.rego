package wiz

# --- Configuration ---
required_containers := {"examplefinancearchive", "exampleauditlogs"}

# --- Logic ---
default result := "pass"

is_required_container {
    required_containers[input.name]
}

# A container-level policy protects the container's blobs. Version-level
# immutability support alone sets no retention, and a default policy set on
# the account does not appear on the container.
is_immutable {
    input.properties.hasImmutabilityPolicy == true
}

versioning_only {
    not is_immutable
    input.properties.immutableStorageWithVersioning.enabled == true
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
} else := val {
    versioning_only
    val := "Version-level support is on but no policy is set on the container; effective immutability protection cannot be verified from this container payload"
} else := "No immutability policy and no version-level support"

currentConfiguration := sprintf("Immutability policy is '%v' for container '%v'", [current_state, input.name])
expectedConfiguration := "Required containers have an immutability policy set on the container. A default policy inherited from the account is not in the container payload, so protection from it cannot be verified here."