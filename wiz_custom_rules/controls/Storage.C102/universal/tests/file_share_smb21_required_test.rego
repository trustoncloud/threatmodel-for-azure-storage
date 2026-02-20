package wiz

# 1. PASS: Modern version only
test_universal_pass_modern {
    result == "pass" with input as {
        "properties": {"protocolSettings": {"smb": {"versions": "SMB3.0"}}}
    }
}

# 2. FAIL: Contains SMB 2.1
test_universal_fail_legacy {
    result == "fail" with input as {
        "properties": {"protocolSettings": {"smb": {"versions": "SMB2.1;SMB3.0"}}}
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