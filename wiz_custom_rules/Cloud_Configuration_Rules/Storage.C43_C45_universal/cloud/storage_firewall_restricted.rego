package wiz

# --- Logic ---
default result := "pass"

has_network_acls {
    input.properties.networkAcls != null
}

public_by_default {
    input.properties.networkAcls.defaultAction == "Allow"
}

has_any_ip_rules {
    count(input.properties.networkAcls.ipRules) > 0
}

result := "skip" {
    not input.properties
} else := "skip" {
    not has_network_acls
} else := "fail" {
    public_by_default
} else := "fail" {
    has_any_ip_rules
}

# --- Metadata ---
currentConfiguration := sprintf("Default action: '%v'. IP rules count: %v", [input.properties.networkAcls.defaultAction, count(input.properties.networkAcls.ipRules)])
expectedConfiguration := "Storage firewall must have defaultAction set to 'Deny' and zero IP rules allowed (Universal Private mode)."