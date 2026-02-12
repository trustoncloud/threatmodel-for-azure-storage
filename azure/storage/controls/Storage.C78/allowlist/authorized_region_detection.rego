package wiz

# --- Configuration ---
allowed_regions := {"eastus", "westeurope", "australiaeast"}

# --- Logic ---
default result := "pass"

location := val {
    val := input.location
} else := val {
    val := input.properties.location
}

is_allowed_region {
    allowed_regions[lower(location)]
}

result := "skip" {
    not location
} else := "fail" {
    not is_allowed_region
}

# --- Metadata ---
currentConfiguration := sprintf("'location' is set to '%v'", [location])
expectedConfiguration := sprintf("Storage account region must be one of: %v", [allowed_regions])