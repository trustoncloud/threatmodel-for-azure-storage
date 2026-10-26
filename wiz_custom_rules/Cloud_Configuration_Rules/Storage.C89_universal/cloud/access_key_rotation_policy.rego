package wiz

# --- Configuration ---
# Longest key expiration period (rotation reminder) an account may set, in
# days. Each access key must also be younger than the period the account sets.
max_key_expiration_days := 90

# --- Logic ---
default result := "pass"

props := object.get(input, "properties", {})

# Shared Key off means the access keys authorize nothing; an absent
# allowSharedKeyAccess means it is on.
shared_key_disabled {
    props.allowSharedKeyAccess == false
}

# The period is reported under keyPolicy, and also at the top level.
policy_days := days {
    days := object.get(object.get(props, "keyPolicy", {}), "keyExpirationPeriodInDays", null)
    is_number(days)
} else := days {
    days := object.get(input, "KeyExpirationPeriodInDays", null)
    is_number(days)
}

# Key creation times arrive as RFC3339 strings, plain or wrapped in {"Time": ...}.
key_created_ns(v) := ns {
    is_string(v)
    ns := time.parse_rfc3339_ns(v)
} else := ns {
    is_object(v)
    ns := time.parse_rfc3339_ns(v.Time)
}

day_ns := 86400000000000

stale_keys := {k |
    created := object.get(props, "keyCreationTime", {})
    is_object(created)
    v := created[k]
    age_days := (time.now_ns() - key_created_ns(v)) / day_ns
    age_days > policy_days
}

result := "skip" {
    not input.name
} else := "skip" {
    shared_key_disabled
} else := "fail" {
    not policy_days
} else := "fail" {
    policy_days > max_key_expiration_days
} else := "fail" {
    count(stale_keys) > 0
}

# --- Metadata ---
currentConfiguration := "Shared Key is enabled and no key expiration policy is set" {
    not policy_days
} else := sprintf("Key expiration period %v days; keys older than it: %v", [policy_days, stale_keys])

expectedConfiguration := sprintf("Accounts that allow Shared Key set a key expiration period of at most %v days and rotate both keys within it", [max_key_expiration_days])
