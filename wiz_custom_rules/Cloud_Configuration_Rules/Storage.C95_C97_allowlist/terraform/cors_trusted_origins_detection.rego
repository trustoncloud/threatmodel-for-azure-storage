package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
allowed_origins := {"https://myapp.contoso.com", "https://api.contoso.com"}
allowed_methods := {"GET", "POST", "PUT"}
allowed_headers := {"Content-Type", "x-ms-blob-content-type"}
allowed_exposed_headers := {"x-ms-request-id"}
max_authorized_age := 200

# --- Helpers ---
# Service blocks on azurerm_storage_account that hold cors_rule blocks.
# queue_properties exists only in azurerm 4.x.
tf_account_cors_blocks := ["blob_properties", "queue_properties", "share_properties"]

# Standalone resources that hold the queue and table service CORS rules.
tf_standalone_cors_types := ["azurerm_storage_account_queue_properties", "azurerm_storage_account_table_properties"]

# Every cors_rule in a document, with the resource that declares it. cors_rule
# is repeatable: getArray normalizes the object-or-list rendering to a list.
tf_cors_rules(document) := {entry |
    resource := document.resource.azurerm_storage_account[name]
    svc := tf_account_cors_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    rule := terraLib.getArray(block.cors_rule)[ridx]
    entry := {
        "type": "azurerm_storage_account",
        "name": name,
        "resource": resource,
        "path": sprintf("%s.cors_rule[%d]", [svc, ridx]),
        "rule": rule,
    }
} | {entry |
    rtype := tf_standalone_cors_types[_]
    resource := document.resource[rtype][name]
    rule := terraLib.getArray(resource.cors_rule)[ridx]
    entry := {
        "type": rtype,
        "name": name,
        "resource": resource,
        "path": sprintf("cors_rule[%d]", [ridx]),
        "rule": rule,
    }
}

# Each CORS field outside its authorized set, as [field path, expected, actual].
tf_cors_violations(rule) := {v |
    origin := rule.allowed_origins[oidx]
    not allowed_origins[origin]
    v := [sprintf("allowed_origins[%d]", [oidx]), sprintf("allowed_origins entries must be in %v", [allowed_origins]), sprintf("allowed_origins entry '%v' is not authorized", [origin])]
} | {v |
    method := rule.allowed_methods[midx]
    not allowed_methods[method]
    v := [sprintf("allowed_methods[%d]", [midx]), sprintf("allowed_methods entries must be in %v", [allowed_methods]), sprintf("allowed_methods entry '%v' is not authorized", [method])]
} | {v |
    header := rule.allowed_headers[hidx]
    not allowed_headers[header]
    v := [sprintf("allowed_headers[%d]", [hidx]), sprintf("allowed_headers entries must be in %v", [allowed_headers]), sprintf("allowed_headers entry '%v' is not authorized", [header])]
} | {v |
    header := rule.exposed_headers[hidx]
    not allowed_exposed_headers[header]
    v := [sprintf("exposed_headers[%d]", [hidx]), sprintf("exposed_headers entries must be in %v", [allowed_exposed_headers]), sprintf("exposed_headers entry '%v' is not authorized", [header])]
} | {v |
    rule.max_age_in_seconds > max_authorized_age
    v := ["max_age_in_seconds", sprintf("max_age_in_seconds must be <= %d", [max_authorized_age]), sprintf("max_age_in_seconds is %v (exceeds cap)", [rule.max_age_in_seconds])]
}

# --- Logic ---
# One finding per CORS field outside the authorized sets, in the blob, file,
# queue and table services.
WizPolicy[result] {
    document := input.document[i]
    entry := tf_cors_rules(document)[_]
    v := tf_cors_violations(entry.rule)[_]

    result := {
        "documentId": document.id,
        "resourceType": entry.type,
        "resourceName": terraLib.get_resource_name(entry.resource, entry.name),
        "searchKey": sprintf("%s[%s].%s.%s", [entry.type, entry.name, entry.path, v[0]]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": v[1],
        "keyActualValue": v[2],
        "resourceTags": terraLib.get_resource_tags(entry.resource),
    }
}
