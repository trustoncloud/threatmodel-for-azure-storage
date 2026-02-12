package wiz

# 1. PASS: SAS is disabled
test_pass_sas_disabled {
    result == "pass" with input as {
        "name": "any-account",
        "properties": {"allowSharedKeyAccess": false}
    }
}

# 2. FAIL: SAS is enabled (Universal fails everyone)
test_fail_sas_enabled {
    result == "fail" with input as {
        "name": "backup_storage_prod",
        "properties": {"allowSharedKeyAccess": true}
    }
}

# 3. SKIP: Missing property field
test_skip_missing_sas_field {
    result == "skip" with input as {
        "name": "incomplete-resource",
        "properties": {}
    }
}