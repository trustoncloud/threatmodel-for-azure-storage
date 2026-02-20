package wiz

# 1. PASS: CORS is disabled (No rules exist)
test_universal_pass_disabled {
    result == "pass" with input as {
        "properties": {
            "cors": {
                "corsRules": []
            }
        }
    }
}

# 2. FAIL: CORS is enabled with a "secure" rule
# In Universal mode, even a restricted rule is a failure.
test_universal_fail_enabled_secure {
    result == "fail" with input as {
        "properties": {
            "cors": {
                "corsRules": [{
                    "allowedOrigins": ["https://myapp.contoso.com"],
                    "allowedMethods": ["GET"],
                    "maxAgeInSeconds": 100
                }]
            }
        }
    }
}

# 3. FAIL: CORS is enabled with an insecure rule
test_universal_fail_enabled_insecure {
    result == "fail" with input as {
        "properties": {
            "cors": {
                "corsRules": [{
                    "allowedOrigins": ["*"],
                    "allowedMethods": ["GET", "POST", "DELETE", "PUT"]
                }]
            }
        }
    }
}

# 4. SKIP: Missing property block
test_universal_skip_missing {
    result == "skip" with input as {
        "name": "incomplete-resource"
    }
}