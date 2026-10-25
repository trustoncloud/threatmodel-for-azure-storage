package wiz

# --- Logic ---
default result := "pass"

props := object.get(input, "properties", {})

# Local users sign in only over SFTP, and isLocalUserEnabled defaults to
# true, so an account is exposed when SFTP is on and local users are not off.
sftp_local_users_on {
    props.isSftpEnabled == true
    object.get(props, "isLocalUserEnabled", true) != false
}

result := "skip" {
    not input.properties
} else := "fail" {
    sftp_local_users_on
}

# --- Metadata ---
currentConfiguration := sprintf("SFTP enabled: %v, local users enabled: %v", [
    object.get(props, "isSftpEnabled", false),
    object.get(props, "isLocalUserEnabled", true)
])

expectedConfiguration := "SFTP with local users is disabled on every storage account"
