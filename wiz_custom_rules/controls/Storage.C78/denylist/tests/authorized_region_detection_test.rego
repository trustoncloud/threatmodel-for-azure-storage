package wiz

# 1. FAIL: Account is in a forbidden region
test_denylist_fail_forbidden {
    result == "fail" with input as {"name": "expensive-store", "location": "brazilsouth"}
}

# 2. PASS: Account is in a region NOT on the denylist
test_denylist_pass_allowed {
    result == "pass" with input as {"name": "standard-store", "location": "eastus"}
}

# 3. SKIP: No location data
test_denylist_skip_no_location {
    result == "skip" with input as {"name": "missing-data"}
}