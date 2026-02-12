package wiz

# 1. PASS: Required share is compliant
test_allowlist_pass_required_compliant {
    result == "pass" with input as {
        "name": "finance-share",
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "AES-256",
            "channelEncryption": "AES-256-GCM"
        }}}
    }
}

# 2. PASS: Non-required share with weak encryption (Allowed)
test_allowlist_pass_not_required {
    result == "pass" with input as {
        "name": "dev-sandbox",
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "RC4-HMAC",
            "channelEncryption": "AES-128-CCM"
        }}}
    }
}

# 3. FAIL: Required share is missing AES-256
test_allowlist_fail_required_weak {
    result == "fail" with input as {
        "name": "hr-share",
        "properties": {"protocolSettings": {"smb": {
            "kerberosTicketEncryption": "AES-128",
            "channelEncryption": "AES-128-GCM"
        }}}
    }
}