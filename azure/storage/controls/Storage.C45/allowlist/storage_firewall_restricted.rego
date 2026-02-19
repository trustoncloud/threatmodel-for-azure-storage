package wiz

# --- Configuration ---
# List of authorized CIDRs or IPs (e.g., Office VPN, Build Servers)
authorized_ips := {
    "20.50.100.10/32",
    "40.70.150.0/24"
}

# --- Logic ---

default result := "pass"

# Helper: Check if network rules exist
has_network_acls {
    input.properties.networkAcls != null
}

# Rule 1: Identify if the default action is 'Allow' (Publicly open)
public_by_default {
    input.properties.networkAcls.defaultAction == "Allow"
}

# Rule 2: Identify any unauthorized IP in the firewall list
unauthorized_ip_rules[ip] {
    rule := input.properties.networkAcls.ipRules[_]
    ip := rule.value
    not authorized_ips[ip]
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    not has_network_acls
} else := "fail" {
    public_by_default
} else := "fail" {
    count(unauthorized_ip_rules) > 0
}

# --- Metadata ---

actual_default := input.properties.networkAcls.defaultAction { has_network_acls } else := "unknown"

currentConfiguration := sprintf("Default action: '%v'. Unauthorized IPs found: %v", [actual_default, unauthorized_ip_rules])

expectedConfiguration := "defaultAction must be 'Deny' and all ipRules must be in the authorized list."