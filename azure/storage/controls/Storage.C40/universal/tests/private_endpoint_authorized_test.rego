package wiz

# 1. PASS: All connections are approved
test_universal_pass_approved {
    result == "pass" with input as {
        "properties": {"privateEndpointConnections": [
            {"name": "pe1", "properties": {"privateLinkServiceConnectionState": {"status": "Approved"}}}
        ]}
    }
}

# 2. FAIL: One connection is Pending
test_universal_fail_pending {
    result == "fail" with input as {
        "properties": {"privateEndpointConnections": [
            {"name": "pe1", "properties": {"privateLinkServiceConnectionState": {"status": "Pending"}}}
        ]}
    }
}

# 3. SKIP: No connections present
test_universal_skip_empty {
    result == "skip" with input as {"properties": {}}
}