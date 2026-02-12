package wiz

# 1. PASS: Single authorized IP rule with correct Deny action
test_firewall_pass_single_authorized {
    result == "pass" with input as {
        "properties": {"networkAcls": {
            "defaultAction": "Deny",
            "ipRules": [{"value": "20.50.100.10/32"}]
        }}
    }
}

# 2. PASS: Multiple authorized IP rules (Array processing)
test_firewall_pass_multi_authorized {
    result == "pass" with input as {
        "properties": {"networkAcls": {
            "defaultAction": "Deny",
            "ipRules": [
                {"value": "20.50.100.10/32"},
                {"value": "40.70.150.0/24"}
            ]
        }}
    }
}

# 3. FAIL: Mixed values - contains one authorized and one UNAUTHORIZED IP
test_firewall_fail_mixed_ips {
    result == "fail" with input as {
        "properties": {"networkAcls": {
            "defaultAction": "Deny",
            "ipRules": [
                {"value": "20.50.100.10/32"}, # Authorized
                {"value": "9.9.9.9/32"}        # UNAUTHORIZED
            ]
        }}
    }
}

# 4. FAIL: Single unauthorized IP
test_firewall_fail_unauthorized_ip {
    result == "fail" with input as {
        "properties": {"networkAcls": {
            "defaultAction": "Deny",
            "ipRules": [{"value": "1.1.1.1/32"}]
        }}
    }
}

# 5. FAIL: Default action is 'Allow' (Publicly open) regardless of IP rules
test_firewall_fail_public_access {
    result == "fail" with input as {
        "properties": {"networkAcls": {
            "defaultAction": "Allow",
            "ipRules": [{"value": "20.50.100.10/32"}]
        }}
    }
}

# 6. SKIP: Missing networkAcls block (Scanner failed or property absent)
test_firewall_skip_missing_data {
    result == "skip" with input as {
        "properties": {}
    }
}