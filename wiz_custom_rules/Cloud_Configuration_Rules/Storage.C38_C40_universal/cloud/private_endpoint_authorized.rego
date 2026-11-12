package wiz

# --- Logic ---
default result := "pass"

connection_status(connection) := object.get(object.get(object.get(connection, "properties", {}), "privateLinkServiceConnectionState", {}), "status", "")

violations[msg] {
    connection := input.properties.privateEndpointConnections[_]
    status := connection_status(connection)

    # Condition: Connection status is anything other than Approved
    status != "Approved"
    msg := sprintf("Connection '%v' is in unapproved state: '%v'", [object.get(connection, "name", ""), status])
}

result := "skip" {
    not input.properties.privateEndpointConnections
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Unapproved connections: %v", [violations])
expectedConfiguration := "All existing private endpoint connections must be in the 'Approved' state."