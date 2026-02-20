package wiz

# 1. PASS: Authorized account using SMB 2.1
test_allowlist_pass_authorized {
    result == "pass" with input as {
        "name": "legacy-app-storage",
        "properties": {"protocolSettings": {"smb": {"versions": "SMB2.1;SMB3.0"}}}
    }
}

# 2. FAIL: Unauthorized account using SMB 2.1
test_allowlist_fail_unauthorized {
    result == "fail" with input as {
        "name": "new-prod-share",
        "properties": {"protocolSettings": {"smb": {"versions": "SMB2.1;SMB3.0"}}}
    }
}

# 3. PASS: Unauthorized account using only SMB 3.0
test_allowlist_pass_standard {
    result == "pass" with input as {
        "name": "new-prod-share",
        "properties": {"protocolSettings": {"smb": {"versions": "SMB3.0"}}}
    }
}

# 4. SKIP: Missing smb block
test_skip_missing_smb {
    result == "skip" with input as {
        "properties": {
            "protocolSettings": {}
        }
    }
}