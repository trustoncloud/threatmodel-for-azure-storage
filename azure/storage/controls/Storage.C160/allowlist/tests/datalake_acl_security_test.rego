package wiz

# 1. PASS: Authorized Data Lake exception
test_allowlist_pass_authorized_exception {
    result == "pass" with input as {
        "name": "legacy-hadoop-migration",
        "properties": { "isHnsEnabled": true, "allowSharedKeyAccess": true }
    }
}

# 2. SKIP: Unauthorized Standard storage (Not a Data Lake)
test_allowlist_skip_standard {
    result == "skip" with input as {
        "name": "new-prod-datalake",
        "properties": { "isHnsEnabled": false, "allowSharedKeyAccess": true }
    }
}

# 3. FAIL: Unauthorized Vulnerable Data Lake
test_allowlist_fail_unauthorized_vulnerable {
    result == "fail" with input as {
        "name": "new-prod-datalake",
        "properties": { "isHnsEnabled": true, "allowSharedKeyAccess": true }
    }
}