package wiz

# --- Configuration ---
# Regions where storage accounts are EXPLICITLY FORBIDDEN
forbidden_regions := {"brazilsouth", "centralindia", "southafricanorth"}

# --- Logic ---
default result := "pass"

location := val {
    val := input.location
    is_string(val)
}

# Regions holding the account's data: the primary location and, for
# geo-redundant accounts, the paired secondary region Azure replicates to.
data_regions[r] {
    r := lower(location)
}

data_regions[r] {
    secondary := object.get(object.get(input, "properties", {}), "secondaryLocation", "")
    is_string(secondary)
    secondary != ""
    r := lower(secondary)
}

forbidden_found := {r | r := data_regions[_]; forbidden_regions[r]}

result := "skip" {
    not location
} else := "fail" {
    count(forbidden_found) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Account data is held in %v; forbidden: %v", [data_regions, forbidden_found])
expectedConfiguration := sprintf("Neither the primary nor any secondary region may be one of: %v", [forbidden_regions])