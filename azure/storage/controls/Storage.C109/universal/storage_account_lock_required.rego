package wiz

# --- Configuration ---
valid_lock_levels := {"CanNotDelete", "ReadOnly"}

# --- Logic ---
default result := "pass"

locks := val {
    val := input.managementLocks
} else := val {
    val := input.locks
}

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
} else := "fail" {
    not locks
} else := "fail" {
    not has_required_lock
}

# --- Metadata ---
current_levels := {l | lock := locks[_]; l := lock.level} {
    locks != null
} else := {l | lock := locks[_]; l := lock.properties.level} {
    locks != null
} else := {"None"}

currentConfiguration := sprintf("Account '%v' has lock levels: %v", [input.name, current_levels])
expectedConfiguration := "All storage accounts must have at least one 'CanNotDelete' or 'ReadOnly' lock applied."