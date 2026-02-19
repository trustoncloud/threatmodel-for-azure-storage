package wiz

# --- Configuration ---
required_lock_accounts := {"prod-storage-01", "billing-archive"}
valid_lock_levels := {"CanNotDelete", "ReadOnly"}

# --- Logic ---
default result := "pass"

# Support both joined scanner data and direct lock resource objects
locks := val {
    val := input.managementLocks
} else := val {
    val := input.locks
}

is_required_account {
    required_lock_accounts[input.name]
}

# Handles both direct level access and nested properties.level
has_required_lock {
    lock := locks[_]
    valid_lock_levels[lock.level]
}
has_required_lock {
    lock := locks[_]
    valid_lock_levels[lock.properties.level]
}

# Logic Chain
result := "skip" {
    not input.name
} else := "pass" {
    not is_required_account
} else := "fail" {
    is_required_account
    not locks
} else := "fail" {
    is_required_account
    not has_required_lock
}

# --- Metadata ---
current_levels := {l | lock := locks[_]; l := lock.level} {
    locks != null
} else := {l | lock := locks[_]; l := lock.properties.level} {
    locks != null
} else := {"None"}

currentConfiguration := sprintf("Account '%v' has lock levels: %v", [input.name, current_levels])
expectedConfiguration := "Required storage accounts must have at least one 'CanNotDelete' or 'ReadOnly' lock applied."