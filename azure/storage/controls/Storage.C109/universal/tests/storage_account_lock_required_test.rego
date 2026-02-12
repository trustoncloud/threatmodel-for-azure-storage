package wiz

# 1. PASS: Account has a valid lock
test_universal_pass_with_lock {
    result == "pass" with input as {
        "name": "any-storage",
        "managementLocks": [{"level": "CanNotDelete"}]
    }
}

# 2. FAIL: Account has no locks
test_universal_fail_no_locks {
    result == "fail" with input as {
        "name": "any-storage",
        "managementLocks": []
    }
}

# 3. FAIL: Account has a lock but wrong level
test_universal_fail_invalid_level {
    result == "fail" with input as {
        "name": "any-storage",
        "managementLocks": [{"level": "NotSpecified"}]
    }
}