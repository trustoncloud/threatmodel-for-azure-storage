package wiz

# --- Configuration ---
authorized_legacy_datalakes := {"legacy-hadoop-migration", "temp-ingest-lake"}

# --- Logic ---
# Explicitly set the default to fail so we catch logic gaps
default result := "fail"

is_authorized {
    authorized_legacy_datalakes[input.name]
}

# Scope: only HNS (Data Lake Gen2) accounts. isHnsEnabled is absent for
# non-HNS accounts, so scope on an explicit true.
is_datalake {
    input.properties.isHnsEnabled == true
}

# Logic Chain: Order Matters!
result := "skip" {
    not input.properties
} else := "skip" {
    # 1. Not a Data Lake (HNS false or absent) -> out of scope immediately
    not is_datalake
} else := "pass" {
    # 2. If it's authorized, it passes regardless of SharedKey status
    is_authorized
} else := "pass" {
    # 3. If unauthorized but SECURE, it passes
    input.properties.isHnsEnabled == true
    input.properties.allowSharedKeyAccess == false
} else := "fail" {
    # 4. If unauthorized and VULNERABLE, it fails
    input.properties.isHnsEnabled == true
    input.properties.allowSharedKeyAccess == true
}

# --- Metadata ---
currentConfiguration := sprintf("Account '%v': HNS=%v, SharedKey=%v", [input.name, input.properties.isHnsEnabled, input.properties.allowSharedKeyAccess])
expectedConfiguration := "Shared Key access on Data Lake Gen2 is restricted to authorized legacy accounts only."