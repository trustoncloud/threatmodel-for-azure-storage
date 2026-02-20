package wiz

# --- Logic ---
default result := "pass"

violations[msg] {
    connection := input.properties.privateEndpointConnections[_]
    status := connection.properties.privateLinkServiceConnectionState.status
    
    # Condition: Connection is not approved (e.g., Pending, Rejected)
    status != "Approved"
    msg := sprintf("Connection %v is in unapproved state: %v", [connection.name, status])
}

result := "skip" {
    not input.properties.privateEndpointConnections
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Unapproved connections: %v", [violations])
expectedConfiguration := "All existing private endpoint connections must be in the 'Approved' state."