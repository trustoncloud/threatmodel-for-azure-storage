package wiz

# --- Configuration ---
# List of authorized CIDRs or IPs (e.g., Office VPN, Build Servers)
authorized_ips := {
    "20.50.100.10/32",
    "40.70.150.0/24"
}

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

# Rule 1: Identify if the default action is not 'Deny' (publicly open)
public_by_default {
    default_action != "Deny"
}

# An IP rule is authorized if it exactly matches an allowlist entry, or
# falls within an authorized CIDR range (a host IP inside an approved
# subnet, or a bare IP matching an approved /32).
ip_authorized(ip) {
    authorized_ips[ip]
}

ip_authorized(ip) {
    cidr := authorized_ips[_]
    indexof(cidr, "/") != -1
    net.cidr_contains(cidr, ip)
}

# Rule 2: Identify any unauthorized IP in the firewall list
unauthorized_ip_rules[ip] {
    rule := ip_rules[_]
    ip := rule.value
    not ip_authorized(ip)
}

# Logic Chain
has_properties {
    is_object(input.properties)
}

result := "skip" {
    not has_properties
} else := "fail" {
    public_by_default
} else := "fail" {
    count(unauthorized_ip_rules) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Default action: '%v'. Unauthorized IPs found: %v", [default_action, unauthorized_ip_rules])

expectedConfiguration := "defaultAction must be 'Deny' and all ipRules must be in the authorized list."
