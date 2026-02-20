package wiz

# 1. PASS: Account is in the required region
test_universal_pass_correct_region {
    result == "pass" with input as {"name": "prod-store", "location": "eastus"}
}

# 2. FAIL: Account is in a different region
test_universal_fail_wrong_region {
    result == "fail" with input as {"name": "dr-store", "location": "westeurope"}
}

# 3. SKIP: No location data provided
test_universal_skip_no_location {
    result == "skip" with input as {"name": "ghost-resource"}
}