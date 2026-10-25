package wiz

# --- Configuration ---
# Network ACL bypass values you approve: AzureServices, Logging, Metrics.
# "None" (no bypass) always passes.
authorized_network_bypass := {"AzureServices"}

# --- Logic ---
default result := "pass"

acls := object.get(object.get(input, "properties", {}), "networkAcls", {})

# Azure returns the bypass as one comma-separated string; an absent value
# means the AzureServices default.
bypass_values := {trim_space(v) |
    raw := object.get(acls, "bypass", "AzureServices")
    is_string(raw)
    v := split(raw, ",")[_]
    trim_space(v) != ""
}

unauthorized_bypass := {v |
    v := bypass_values[_]
    v != "None"
    not authorized_network_bypass[v]
}

result := "skip" {
    not input.name
} else := "skip" {
    not is_object(acls)
} else := "fail" {
    count(unauthorized_bypass) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Network ACL bypass is %v; not authorized: %v", [bypass_values, unauthorized_bypass])

expectedConfiguration := sprintf("Network ACL bypass uses only: %v", [authorized_network_bypass])
