package wiz

# 1. PASS: Location is in the allowlist
test_allowlist_pass_authorized {
    result == "pass" with input as {"name": "primary-store", "location": "westeurope"}
}

# 2. PASS: Mixed case handling
test_allowlist_pass_case_insensitive {
    result == "pass" with input as {"name": "secondary-store", "location": "EastUS"}
}

# 3. FAIL: Region not in the allowlist
test_allowlist_fail_unauthorized {
    result == "fail" with input as {"name": "shadow-store", "location": "brazilsouth"}
}

# 4. SKIP: Missing location field
test_allowlist_skip_no_location {
    result == "skip" with input as {"name": "incomplete-data"}
}