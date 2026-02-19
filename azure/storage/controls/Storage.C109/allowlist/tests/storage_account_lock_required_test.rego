package wiz

# 1. PASS: Required account has a valid lock
test_allowlist_pass_required_with_lock {
    result == "pass" with input as {
        "name": "prod-storage-01",
        "managementLocks": [{"level": "CanNotDelete"}]
    }
}

# 2. PASS: Non-required account has NO locks (Allowed)
test_allowlist_pass_not_required {
    result == "pass" with input as {
        "name": "dev-temp-storage",
        "managementLocks": []
    }
}

# 3. FAIL: Required account has mixed locks where none are valid
test_allowlist_fail_required_wrong_level {
    result == "fail" with input as {
        "name": "billing-archive",
        "managementLocks": [{"level": "NotSpecified"}, {"properties": {"level": "None"}}]
    }
}

# 4. FAIL: Required account has no locks array at all
test_allowlist_fail_required_missing_array {
    result == "fail" with input as {
        "name": "prod-storage-01"
    }
}