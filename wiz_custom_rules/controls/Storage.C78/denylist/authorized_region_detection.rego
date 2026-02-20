package wiz

# --- Configuration ---
# Regions where storage accounts are EXPLICITLY FORBIDDEN
forbidden_regions := {"brazilsouth", "centralindia", "southafricanorth"}

# --- Logic ---
default result := "pass"

location := val {
    val := input.location
} else := val {
    val := input.properties.location
}

is_forbidden_region {
    forbidden_regions[lower(location)]
}

result := "skip" {
    not location
} else := "fail" {
    is_forbidden_region
}

# --- Metadata ---
currentConfiguration := sprintf("'location' is set to '%v' (Forbidden list: %v)", [location, forbidden_regions])
expectedConfiguration := "Storage accounts are permitted in any region EXCEPT those on the forbidden denylist."