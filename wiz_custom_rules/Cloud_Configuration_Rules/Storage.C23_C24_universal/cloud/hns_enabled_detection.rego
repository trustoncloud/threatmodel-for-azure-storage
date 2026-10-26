package wiz

# --- Logic ---

default result := "pass"

has_hns_config {
    input.properties.isHnsEnabled != null
}

hns_enabled {
    input.properties.isHnsEnabled == true
}

result := "skip" {
    not input.properties
} else := "skip" {
    not has_hns_config
} else := "fail" {
    hns_enabled
}

# --- Metadata ---

actual_value := val {
    has_hns_config
    val := input.properties.isHnsEnabled
} else := "undefined"

currentConfiguration := sprintf("'isHnsEnabled' is set to '%v' for account '%v'", [actual_value, input.name])

expectedConfiguration := "HNS (Data Lake) must be disabled for all storage accounts in this environment."