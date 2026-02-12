package wiz

# 1. PASS: Correct Universal posture (Deny + Zero IP Rules)
test_universal_pass_private {
    result == "pass" with input as {
        "properties": {
            "networkAcls": {
                "defaultAction": "Deny",
                "ipRules": []
            }
        }
    }
}

# 2. FAIL: Default action is Allow (Publicly accessible)
test_universal_fail_public {
    result == "fail" with input as {
        "properties": {
            "networkAcls": {
                "defaultAction": "Allow",
                "ipRules": []
            }
        }
    }
}

# 3. FAIL: Action is Deny, but an IP rule exists (Universal requires zero rules)
test_universal_fail_with_rules {
    result == "fail" with input as {
        "properties": {
            "networkAcls": {
                "defaultAction": "Deny",
                "ipRules": [
                    {"value": "20.50.100.10/32"}
                ]
            }
        }
    }
}

# 4. SKIP: Network ACL configuration is missing entirely
test_universal_skip_missing {
    result == "skip" with input as {
        "properties": {}
    }
}