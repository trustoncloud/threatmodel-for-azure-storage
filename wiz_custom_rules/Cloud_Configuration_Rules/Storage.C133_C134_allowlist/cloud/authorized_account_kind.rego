package wiz

# --- Configuration ---
# Storage account kinds you approve. StorageV2 is the general-purpose kind;
# add BlockBlobStorage or FileStorage alongside only for approved premium
# workloads.
authorized_account_kinds := {"StorageV2"}

# --- Logic ---
default result := "pass"

kind := object.get(input, "kind", "")

result := "skip" {
    not input.name
} else := "skip" {
    not is_string(kind)
} else := "skip" {
    kind == ""
} else := "fail" {
    not authorized_account_kinds[kind]
}

# --- Metadata ---
currentConfiguration := sprintf("Account kind is %v", [kind])

expectedConfiguration := sprintf("Account kind must be one of: %v", [authorized_account_kinds])
