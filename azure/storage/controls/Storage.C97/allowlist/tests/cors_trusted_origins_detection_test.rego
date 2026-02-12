package wiz

# 1. PASS: Multi-rule input where all headers are authorized
test_cors_pass_authorized_headers {
    result == "pass" with input as {
        "properties": {"cors": {"corsRules": [
            {
                "allowedOrigins": ["https://myapp.contoso.com"],
                "allowedMethods": ["GET"],
                "allowedHeaders": ["Content-Type"],
                "exposedHeaders": ["x-ms-request-id"],
                "maxAgeInSeconds": 100
            }
        ]}}
    }
}

# 2. FAIL: One rule contains an unauthorized request header (Mixed Scenario)
test_cors_fail_unauthorized_header {
    result == "fail" with input as {
        "properties": {"cors": {"corsRules": [
            {
                "allowedOrigins": ["https://myapp.contoso.com"],
                "allowedHeaders": ["Content-Type", "Authorization"], # Authorization is NOT allowed
                "maxAgeInSeconds": 100
            }
        ]}}
    }
}

# 3. FAIL: One rule contains an unauthorized exposed header
test_cors_fail_unauthorized_exposed_header {
    result == "fail" with input as {
        "properties": {"cors": {"corsRules": [
            {
                "allowedOrigins": ["https://myapp.contoso.com"],
                "exposedHeaders": ["Secret-Key"], # Secret-Key is NOT allowed
                "maxAgeInSeconds": 100
            }
        ]}}
    }
}

# 4. FAIL: Max Age is too high
test_fail_invalid_max_age {
    result == "fail" with input as {
        "name": "blob-service-age",
        "properties": {
            "cors": {
                "corsRules": [{
                    "allowedOrigins": ["https://myapp.contoso.com"],
                    "allowedMethods": ["GET"],
                    "allowedHeaders": ["Content-Type"],
                    "exposedHeaders": ["x-ms-request-id"],
                    "maxAgeInSeconds": 3600
                }]
            }
        }
    }
}

# 5. SKIP: No CORS rules defined
test_skip_no_cors {
    result == "skip" with input as {
        "properties": {}
    }
}