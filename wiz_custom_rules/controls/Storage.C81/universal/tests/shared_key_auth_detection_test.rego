package wiz
# 1. PASS: Compliant configuration
test_universal_pass {
    result == "pass" with input as {
        "properties": {
            "allowSharedKeyAccess": false,
            "defaultToOAuthAuthentication": true
        }
    }
}

# 2. FAIL: Shared Key is enabled
test_universal_fail_shared_key_enabled {
    result == "fail" with input as {
        "properties": {
            "allowSharedKeyAccess": true,
            "defaultToOAuthAuthentication": true
        }
    }
}

# 3. FAIL: OAuth is not the default
test_universal_fail_oauth_disabled {
    result == "fail" with input as {
        "properties": {
            "allowSharedKeyAccess": false,
            "defaultToOAuthAuthentication": false
        }
    }
}