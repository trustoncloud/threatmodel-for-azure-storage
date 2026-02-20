package wiz

# --- Configuration ---
authorized_endpoints := {
    "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateEndpoints/pe-prod-01",
    "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateEndpoints/pe-prod-02"
}

# --- Logic ---

default result := "pass"

# Helper to find any "Violator" connection
violations[msg] {
    connection := input.properties.privateEndpointConnections[_]
    endpoint_id := connection.properties.privateEndpoint.id
    status := connection.properties.privateLinkServiceConnectionState.status

    # Condition A: Endpoint is not in the allowlist
    not authorized_endpoints[endpoint_id]
    msg := sprintf("Unauthorized endpoint: %v", [endpoint_id])
}

violations[msg] {
    connection := input.properties.privateEndpointConnections[_]
    status := connection.properties.privateLinkServiceConnectionState.status
    
    # Condition B: Connection is not approved (e.g., Pending, Rejected, Disconnected)
    status != "Approved"
    msg := sprintf("Connection for %v is in state: %v", [connection.properties.privateEndpoint.id, status])
}

# Final Result Logic
result := "skip" {
    not input.properties.privateEndpointConnections
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Violations found: %v", [violations])
expectedConfiguration := "All endpoints must be authorized AND their status must be 'Approved'."