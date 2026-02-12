package wiz

# 1. PASS: Authorized ID and Approved
test_allowlist_pass_valid {
    result == "pass" with input as {
        "properties": {"privateEndpointConnections": [{
            "properties": {
                "privateEndpoint": {"id": "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateEndpoints/pe-prod-01"},
                "privateLinkServiceConnectionState": {"status": "Approved"}
            }
        }]}
    }
}

# 2. FAIL: Unauthorized ID
test_allowlist_fail_unauthorized_id {
    result == "fail" with input as {
        "properties": {"privateEndpointConnections": [{
            "properties": {
                "privateEndpoint": {"id": "/subscriptions/unauthorized-sub/pe-malicious"},
                "privateLinkServiceConnectionState": {"status": "Approved"}
            }
        }]}
    }
}

# 3. FAIL: Authorized ID but Pending status
test_allowlist_fail_unapproved_status {
    result == "fail" with input as {
        "properties": {"privateEndpointConnections": [{
            "properties": {
                "privateEndpoint": {"id": "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateEndpoints/pe-prod-01"},
                "privateLinkServiceConnectionState": {"status": "Pending"}
            }
        }]}
    }
}

# 4. SKIP: Missing connections field
test_allowlist_skip_missing {
    result == "skip" with input as {"properties": {}}
}