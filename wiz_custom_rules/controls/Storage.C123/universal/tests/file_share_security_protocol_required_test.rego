package wiz

# 1. PASS: Compliant settings (exact match)
test_universal_pass_exact {
    result == "pass" with input as {
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "AES-256",
            "channelEncryption": "AES-256-GCM"
        }}}
    }
}

# 2. PASS: Compliant settings (within delimited string)
test_universal_pass_multi_value {
    result == "pass" with input as {
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "RC4-HMAC;AES-256",
            "channelEncryption": "AES-128-GCM;AES-256-GCM"
        }}}
    }
}

# 3. FAIL: Missing required encryption level
test_universal_fail_weak_encryption {
    result == "fail" with input as {
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "AES-128",
            "channelEncryption": "AES-128-CCM"
        }}}
    }
}