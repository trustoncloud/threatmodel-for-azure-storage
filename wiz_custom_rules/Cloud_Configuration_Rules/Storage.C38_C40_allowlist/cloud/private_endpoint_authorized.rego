package wiz

# --- Configuration ---
authorized_endpoints := {
    "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateEndpoints/pe-prod-01",
    "/subscriptions/123/resourceGroups/net-rg/providers/Microsoft.Network/privateEndpoints/pe-prod-02"
}

# --- Logic ---

default result := "pass"

# Helper to find any "Violator" connection
endpoint_id(connection) := object.get(object.get(object.get(connection, "properties", {}), "privateEndpoint", {}), "id", "")

connection_status(connection) := object.get(object.get(object.get(connection, "properties", {}), "privateLinkServiceConnectionState", {}), "status", "")

violations[msg] {
    connection := input.properties.privateEndpointConnections[_]
    id := endpoint_id(connection)

    # Condition A: Endpoint is not in the allowlist (IDs compare case-insensitively)
    not tocm_azure_id_allowed(id, authorized_endpoints)
    msg := sprintf("Unauthorized endpoint: '%v'", [id])
}

violations[msg] {
    connection := input.properties.privateEndpointConnections[_]
    status := connection_status(connection)

    # Condition B: Connection status is anything other than Approved
    status != "Approved"
    msg := sprintf("Connection for '%v' is in state: '%v'", [endpoint_id(connection), status])
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

# --- Matching helpers ---
# --- toc-match begin: azureid v1 ---
# Azure resource IDs compare case-insensitively, segment by segment.
tocm_azure_id_norm(id) := n {
    is_string(id)
    n := lower(trim_suffix(trim_space(id), "/"))
    startswith(n, "/subscriptions/")
    not contains(n, "//")
}

tocm_azure_id_equal(a, b) {
    tocm_azure_id_norm(a) == tocm_azure_id_norm(b)
}

tocm_azure_id_allowed(id, allowed) {
    tocm_azure_id_equal(id, allowed[_])
}
# --- toc-match end: azureid v1 ---
