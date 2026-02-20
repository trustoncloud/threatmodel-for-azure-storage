package wiz

# --- Logic ---
default result := "pass"

# Compliance Check: Both SFTP and Local Users must be disabled
is_insecure {
    input.properties.isSftpEnabled == true
}
is_insecure {
    input.properties.localUsersEnabled == true
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "fail" {
    is_insecure
}

# --- Metadata ---
currentConfiguration := sprintf("SFTP Enabled: %v, Local Users Enabled: %v", [
    input.properties.isSftpEnabled, 
    input.properties.localUsersEnabled
])
expectedConfiguration := "SFTP and Local Users must be globally disabled to ensure Entra ID-only access."