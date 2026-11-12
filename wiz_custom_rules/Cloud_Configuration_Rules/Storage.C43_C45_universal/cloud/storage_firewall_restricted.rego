package wiz

# --- Logic ---
default result := "pass"

# Network rules; an absent or null networkAcls leaves Azure's default action, Allow.
network_acls := object.get(input.properties, "networkAcls", null)

default_action := object.get(network_acls, "defaultAction", "Allow") {
    is_object(network_acls)
} else := "Allow"

ip_rules := object.get(network_acls, "ipRules", []) {
    is_object(network_acls)
} else := []

public_by_default {
    default_action != "Deny"
}

has_any_ip_rules {
    count(ip_rules) > 0
}

has_properties {
    is_object(input.properties)
}

result := "skip" {
    not has_properties
} else := "fail" {
    public_by_default
} else := "fail" {
    has_any_ip_rules
}

# --- Metadata ---
currentConfiguration := sprintf("Default action: '%v'. IP rules count: %v", [default_action, count(ip_rules)])
expectedConfiguration := "The storage firewall denies by default and lists no IP rules."
