package wiz

# --- Configuration ---
# Authorized Azure regions (lowercase). A geo-redundant account also holds data
# in its paired region, so list both regions of each pair you use.
allowed_regions := {"eastus", "westus", "westeurope", "northeurope", "australiaeast", "australiasoutheast"}

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

unauthorized_regions := {r | r := data_regions[_]; not allowed_regions[r]}

result := "skip" {
    not location
} else := "fail" {
    count(unauthorized_regions) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Account data is held in %v; not authorized: %v", [data_regions, unauthorized_regions])
expectedConfiguration := sprintf("The primary and any secondary region must be one of: %v", [allowed_regions])