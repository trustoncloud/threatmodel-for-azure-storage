package wiz

# --- Logic ---
# Default to "fail" as a safety net; the skip/pass branches below define the
# precise compliant cases.
default result := "fail"

# Scope: only Hierarchical Namespace (Data Lake Gen2) accounts. isHnsEnabled
# is absent for non-HNS accounts, so scope on an explicit true.
is_datalake {
    input.properties.isHnsEnabled == true
}

# Logic Chain
result := "skip" {
    not input.properties
} else := "skip" {
    # Not a Data Lake (HNS false or absent) -> out of scope for C160
    not is_datalake
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