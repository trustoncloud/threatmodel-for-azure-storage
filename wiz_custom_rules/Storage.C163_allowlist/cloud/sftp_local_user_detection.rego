package wiz

# --- Configuration ---
authorized_sftp_accounts := {"vendor-upload-share", "legacy-ftp-bridge"}

# --- Logic ---
default result := "pass"

is_authorized {
    authorized_sftp_accounts[input.name]
}

is_insecure {
    input.properties.isSftpEnabled == true
}
is_insecure {
    input.properties.localUsersEnabled == true
}

# Logic Chain
result := "skip" {
    not input.name
} else := "pass" {
    is_authorized
} else := "fail" {
    is_insecure
}

# --- Metadata ---
currentConfiguration := sprintf("Account '%v' has SFTP: %v, LocalUsers: %v", [
    input.name, 
    input.properties.isSftpEnabled, 
    input.properties.localUsersEnabled
])
expectedConfiguration := "SFTP and Local Users are only permitted on authorized bridge/vendor storage accounts."