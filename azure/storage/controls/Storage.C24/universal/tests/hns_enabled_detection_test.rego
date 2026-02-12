package wiz

# Test 1: FAIL - HNS is enabled (This should always fail in Universal mode)
test_universal_fail_enabled {
    result == "fail" with input as {
        "name": "any-storage-account",
        "properties": {
            "isHnsEnabled": true
        }
    }
}

# Test 2: PASS - HNS is disabled (Correct posture for Universal)
test_universal_pass_disabled {
    result == "pass" with input as {
        "name": "standard-storage",
        "properties": {
            "isHnsEnabled": false
        }
    }
}

# Test 3: SKIP - Missing property
test_universal_skip_missing_data {
    result == "skip" with input as {
        "name": "incomplete-resource",
        "properties": {}
    }
}