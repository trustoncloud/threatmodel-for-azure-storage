package wiz

# --- Configuration ---
# Set the single authorized region for the entire environment
required_region := "eastus"

# --- Logic ---
default result := "pass"

location := val {
    val := input.location
} else := val {
    val := input.properties.location
}

is_authorized_region {
    lower(location) == required_region
}

result := "skip" {
    not location
} else := "fail" {
    not is_authorized_region
}

# --- Metadata ---
currentConfiguration := sprintf("'location' is set to '%v'", [location])
expectedConfiguration := sprintf("All storage accounts must be located in: %v", [required_region])