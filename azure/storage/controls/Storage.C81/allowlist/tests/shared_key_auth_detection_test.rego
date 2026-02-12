package wiz

# 1. PASS: Required account is compliant
test_allowlist_pass_required_compliant {
    result == "pass" with input as {
        "name": "finance-archive",
        "properties": {
            "allowSharedKeyAccess": false,
            "defaultToOAuthAuthentication": true
        }
    }
}

# 2. PASS: Non-required account has insecure settings (Allowed)
test_allowlist_pass_not_required {
    result == "pass" with input as {
        "name": "temp-dev-share",
        "properties": {
            "allowSharedKeyAccess": true,
            "defaultToOAuthAuthentication": false
        }
    }
}

# 3. FAIL: Required account is missing OAuth enforcement
test_allowlist_fail_required_insecure {
    result == "fail" with input as {
        "name": "audit-logs",
        "properties": {
            "allowSharedKeyAccess": false,
            "defaultToOAuthAuthentication": false
        }
    }
}