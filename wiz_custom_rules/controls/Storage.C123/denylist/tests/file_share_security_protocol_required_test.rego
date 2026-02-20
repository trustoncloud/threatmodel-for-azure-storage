package wiz

# 1. PASS: Only modern/unlisted methods are used
test_denylist_pass_clean {
    result == "pass" with input as {
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "AES-256",
            "channelEncryption": "AES-256-GCM"
        }}}
    }
}

# 2. FAIL: Contains a forbidden method (RC4)
test_denylist_fail_forbidden_single {
    result == "fail" with input as {
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "RC4-HMAC",
            "channelEncryption": "AES-256-GCM"
        }}}
    }
}

# 3. FAIL: Mixed values (One Good + One FORBIDDEN)
# This is the "Mixed Fail" scenario we established as a factory requirement.
test_denylist_fail_mixed_values {
    result == "fail" with input as {
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "AES-256",
            "channelEncryption": "AES-256-GCM;AES-128-GCM" # AES-128-GCM is forbidden
        }}}
    }
}

# 4. SKIP: Missing SMB block
test_denylist_skip_missing {
    result == "skip" with input as {"properties": {}}
}