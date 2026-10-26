package wiz

# --- Configuration ---
# Longest lifetime a SAS token signed with an account key may request, in
# Azure's D.HH:MM:SS form. Shorten or lengthen it to your approved maximum.
max_sas_expiration_period := "1.00:00:00"

# true: a token requesting a longer lifetime must be blocked.
# false: the policy may only log it.
require_sas_expiration_block := true

# --- Logic ---
default result := "pass"

props := object.get(input, "properties", {})

# Shared Key off means no SAS can be signed with an account key; an absent
# allowSharedKeyAccess means it is on.
shared_key_disabled {
    props.allowSharedKeyAccess == false
}

sas_policy := object.get(props, "sasPolicy", null)

has_sas_policy {
    is_object(sas_policy)
    is_string(sas_policy.sasExpirationPeriod)
}

# D.HH:MM:SS (or HH:MM:SS) to seconds.
period_seconds(p) := secs {
    parts := split(p, ".")
    count(parts) == 2
    hms := split(parts[1], ":")
    secs := (((to_number(parts[0]) * 24) + to_number(hms[0])) * 60 + to_number(hms[1])) * 60 + to_number(hms[2])
} else := secs {
    hms := split(p, ":")
    count(hms) == 3
    secs := ((to_number(hms[0]) * 60) + to_number(hms[1])) * 60 + to_number(hms[2])
}

period_too_long {
    period_seconds(sas_policy.sasExpirationPeriod) > period_seconds(max_sas_expiration_period)
}

action_not_block {
    require_sas_expiration_block
    object.get(sas_policy, "expirationAction", "Log") != "Block"
}

result := "skip" {
    not input.name
} else := "skip" {
    shared_key_disabled
} else := "fail" {
    not has_sas_policy
} else := "fail" {
    period_too_long
} else := "fail" {
    action_not_block
}

# --- Metadata ---
currentConfiguration := "Shared Key is enabled and no SAS expiration policy is set" {
    not has_sas_policy
} else := sprintf("SAS expiration policy: period %v, action %v", [sas_policy.sasExpirationPeriod, object.get(sas_policy, "expirationAction", "Log")]) {
    has_sas_policy
} else := "Shared Key is disabled"

expectedConfiguration := sprintf("Accounts that allow Shared Key set a SAS expiration policy of at most %v, with action Block when required", [max_sas_expiration_period])
