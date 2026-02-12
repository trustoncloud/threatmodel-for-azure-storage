package wiz

# 1. PASS: SAS is disabled (Standard secure posture)
test_pass_sas_disabled {
    result == "pass" with input as {
        "name": "secure-storage",
        "properties": {"allowSharedKeyAccess": false}
    }
}

# 2. FAIL: SAS is enabled on an unauthorized account
test_fail_sas_unauthorized {
    result == "fail" with input as {
        "name": "random-account",
        "properties": {"allowSharedKeyAccess": true}
    }
}

# 3. PASS: SAS is enabled but the account is authorized in the allowlist
test_pass_sas_authorized_exception {
    result == "pass" with input as {
        "name": "backup_storage_prod",
        "properties": {"allowSharedKeyAccess": true}
    }
}

# 4. SKIP: Missing property field
test_skip_missing_sas_field {
    result == "skip" with input as {
        "name": "incomplete-resource",
        "properties": {}
    }
}