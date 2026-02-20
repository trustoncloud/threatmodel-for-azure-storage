package wiz

# 1. FAIL: Contains forbidden SMB 2.1
test_denylist_fail_forbidden {
    result == "fail" with input as {
        "properties": {"protocolSettings": {"smb": {"versions": "SMB2.1;SMB3.0"}}}
    }
}

# 2. PASS: Only unlisted versions
test_denylist_pass_clean {
    result == "pass" with input as {
        "properties": {"protocolSettings": {"smb": {"versions": "SMB3.1.1"}}}
    }
}

# 3. SKIP: Missing smb block
test_skip_missing_smb {
    result == "skip" with input as {
        "properties": {
            "protocolSettings": {}
        }
    }
}