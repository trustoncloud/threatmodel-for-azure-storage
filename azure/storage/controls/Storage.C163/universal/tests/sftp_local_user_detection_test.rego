package wiz

# 1. PASS: Both features are disabled
test_universal_pass_disabled {
    result == "pass" with input as {
        "properties": {
            "isSftpEnabled": false,
            "localUsersEnabled": false
        }
    }
}

# 2. FAIL: SFTP is enabled
test_universal_fail_sftp {
    result == "fail" with input as {
        "properties": {
            "isSftpEnabled": true,
            "localUsersEnabled": false
        }
    }
}

# 3. FAIL: Local Users enabled even if SFTP is disabled
test_universal_fail_local_users_only {
    result == "fail" with input as {
        "properties": {
            "isSftpEnabled": false,
            "localUsersEnabled": true
        }
    }
}

# 4. SKIP: Missing properties block entirely
test_universal_skip_no_properties {
    result == "skip" with input as {
        "name": "incomplete-resource"
    }
}

# 5. PASS: Properties exist but both features are explicitly null/absent
# (Azure defaults these to false if not specified)
test_universal_pass_implicit_false {
    result == "pass" with input as {
        "properties": {}
    }
}