package wiz

# 1. PASS: Secure Data Lake
test_universal_pass_secure_lake {
    result == "pass" with input as {
        "properties": {
            "isHnsEnabled": true,
            "allowSharedKeyAccess": false
        }
    }
}

# 2. SKIP: Standard storage (HNS disabled) is now correctly skipped
test_universal_skip_standard_storage {
    result == "skip" with input as {
        "properties": {
            "isHnsEnabled": false,
            "allowSharedKeyAccess": true
        }
    }
}

# 3. FAIL: Vulnerable Data Lake
test_universal_fail_vulnerable_lake {
    result == "fail" with input as {
        "properties": {
            "isHnsEnabled": true,
            "allowSharedKeyAccess": true
        }
    }
}