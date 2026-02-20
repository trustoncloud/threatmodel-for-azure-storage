package wiz

# 1. PASS: Authorized account using SFTP
test_allowlist_pass_authorized {
    result == "pass" with input as {
        "name": "vendor-upload-share",
        "properties": {
            "isSftpEnabled": true,
            "localUsersEnabled": true
        }
    }
}

# 2. FAIL: Unauthorized account has SFTP enabled
test_allowlist_fail_unauthorized {
    result == "fail" with input as {
        "name": "standard-prod-storage",
        "properties": {
            "isSftpEnabled": true,
            "localUsersEnabled": true
        }
    }
}

# 3. PASS: Authorized account with NO SFTP enabled (Allowed)
test_allowlist_pass_authorized_clean {
    result == "pass" with input as {
        "name": "vendor-upload-share",
        "properties": {
            "isSftpEnabled": false,
            "localUsersEnabled": false
        }
    }
}

# 4. FAIL: Unauthorized account enables ONLY Local Users
test_allowlist_fail_unauthorized_local_only {
    result == "fail" with input as {
        "name": "standard-prod-storage",
        "properties": {
            "localUsersEnabled": true
        }
    }
}

# 5. PASS: Unauthorized account with both disabled
test_allowlist_pass_unauthorized_clean {
    result == "pass" with input as {
        "name": "standard-prod-storage",
        "properties": {
            "isSftpEnabled": false,
            "localUsersEnabled": false
        }
    }
}