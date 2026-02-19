package wiz

# 1. PASS: Container has immutability enabled
test_universal_pass_enabled {
    result == "pass" with input as {
        "name": "any-container",
        "properties": {"immutableStorageWithVersioning": {"enabled": true}}
    }
}

# 2. FAIL: Container has immutability disabled
test_universal_fail_disabled {
    result == "fail" with input as {
        "name": "any-container",
        "properties": {"immutableStorageWithVersioning": {"enabled": false}}
    }
}

# 3. SKIP: Missing property block
test_universal_skip_missing {
    result == "skip" with input as {"properties": {}}
}