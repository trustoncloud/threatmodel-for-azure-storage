package wiz

# 1. PASS: Required container is compliant
test_allowlist_pass_required_enabled {
    result == "pass" with input as {
        "name": "finance-archive",
        "properties": {"immutableStorageWithVersioning": {"enabled": true}}
    }
}

# 2. PASS: Non-required container is mutable (Allowed)
test_allowlist_pass_not_required {
    result == "pass" with input as {
        "name": "temp-scratch-space",
        "properties": {"immutableStorageWithVersioning": {"enabled": false}}
    }
}

# 3. FAIL: Required container has immutability disabled
test_allowlist_fail_required_disabled {
    result == "fail" with input as {
        "name": "audit-logs",
        "properties": {"immutableStorageWithVersioning": {"enabled": false}}
    }
}

# 4. FAIL: Mixed case - Required container missing the property entirely
test_allowlist_fail_required_missing {
    result == "fail" with input as {
        "name": "finance-archive",
        "properties": {}
    }
}