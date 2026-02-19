package wiz

# 1. Test standard pass: HNS is disabled
test_pass_hns_disabled {
	result == "pass" with input as {
		"name": "standard-account",
		"properties": {
			"isHnsEnabled": false
		}
	}
}

# 2. Test fail: HNS is enabled on an unaccepted account
test_fail_hns_enabled {
	result == "fail" with input as {
		"name": "random-account",
		"properties": {
			"isHnsEnabled": true
		}
	}
}

# 3. Test allowlist: HNS is enabled but account is in allowed_hns_accounts
test_pass_hns_allowed_account {
	result == "pass" with input as {
		"name": "data_lake_prod",
		"properties": {
			"isHnsEnabled": true
		}
	}
}

# 4. Test skip: Missing the properties object entirely
test_skip_missing_properties {
	result == "skip" with input as {
		"name": "incomplete-resource"
	}
}

# 5. Test skip: Missing the specific isHnsEnabled field
test_skip_missing_hns_field {
	result == "skip" with input as {
		"name": "partial-resource",
		"properties": {}
	}
}