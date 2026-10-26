package wiz

# --- Configuration ---
# Storage account names allowed to accept SFTP sign-ins from local users.
authorized_sftp_accounts := {"examplevendorupload", "examplelegacyftp"}

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
    not input.name
} else := "pass" {
    authorized_sftp_accounts[input.name]
} else := "fail" {
    sftp_local_users_on
}

# --- Metadata ---
currentConfiguration := sprintf("SFTP enabled: %v, local users enabled: %v", [
    object.get(props, "isSftpEnabled", false),
    object.get(props, "isLocalUserEnabled", true)
])

expectedConfiguration := sprintf("SFTP with local users is enabled only on: %v", [authorized_sftp_accounts])
