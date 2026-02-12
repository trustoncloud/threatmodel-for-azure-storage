package wiz

# --- Logic ---
# Default to "pass" is removed to allow for precise "skip" logic
default result := "fail"

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    # If it's not a Data Lake, it's out of scope for C160
    input.properties.isHnsEnabled == false
} else := "pass" {
    # Secure: HNS is on, and Shared Key is off
    input.properties.isHnsEnabled == true
    input.properties.allowSharedKeyAccess == false
} else := "fail" {
    # Vulnerable: HNS is on, but Shared Key is still on
    input.properties.isHnsEnabled == true
    input.properties.allowSharedKeyAccess == true
}

# --- Metadata ---
hns_status := val { val := input.properties.isHnsEnabled } else := false
key_status := val { val := input.properties.allowSharedKeyAccess } else := true

currentConfiguration := sprintf("HNS Enabled: %v, Shared Key Access: %v", [hns_status, key_status])
expectedConfiguration := "Data Lake Gen2 accounts (HNS=true) must have Shared Key access disabled to enforce ACL integrity."