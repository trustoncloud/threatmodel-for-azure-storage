package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
allowed_origins := {"https://myapp.contoso.com", "https://api.contoso.com"}
allowed_methods := {"GET", "POST", "PUT"}
allowed_headers := {"Content-Type", "x-ms-blob-content-type"}
allowed_exposed_headers := {"x-ms-request-id"}
max_authorized_age := 200

# CORS rules live in three per-service blocks on azurerm_storage_account.
cors_service_blocks := ["blob_properties", "queue_properties", "share_properties"]

# --- Logic ---
# One block per CORS field; each iterates all three service blocks via `svc`.
# cors_rule is a repeatable block: getArray normalizes Wiz's object-or-list
# rendering to a list so a single cors_rule block is still iterated.

# Unauthorized origin
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    svc := cors_service_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    rule := terraLib.getArray(block.cors_rule)[ridx]
    origin := rule.allowed_origins[oidx]
    not allowed_origins[origin]
    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].%s.cors_rule[%d].allowed_origins[%d]", [name, svc, ridx, oidx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("allowed_origins entries must be in %v", [allowed_origins]),
        "keyActualValue": sprintf("allowed_origins entry '%v' is not authorized", [origin]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Unauthorized method
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    svc := cors_service_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    rule := terraLib.getArray(block.cors_rule)[ridx]
    method := rule.allowed_methods[midx]
    not allowed_methods[method]
    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].%s.cors_rule[%d].allowed_methods[%d]", [name, svc, ridx, midx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("allowed_methods entries must be in %v", [allowed_methods]),
        "keyActualValue": sprintf("allowed_methods entry '%v' is not authorized", [method]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Unauthorized request header
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    svc := cors_service_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    rule := terraLib.getArray(block.cors_rule)[ridx]
    header := rule.allowed_headers[hidx]
    not allowed_headers[header]
    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].%s.cors_rule[%d].allowed_headers[%d]", [name, svc, ridx, hidx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("allowed_headers entries must be in %v", [allowed_headers]),
        "keyActualValue": sprintf("allowed_headers entry '%v' is not authorized", [header]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# Unauthorized exposed header
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    svc := cors_service_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    rule := terraLib.getArray(block.cors_rule)[ridx]
    header := rule.exposed_headers[hidx]
    not allowed_exposed_headers[header]
    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].%s.cors_rule[%d].exposed_headers[%d]", [name, svc, ridx, hidx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("exposed_headers entries must be in %v", [allowed_exposed_headers]),
        "keyActualValue": sprintf("exposed_headers entry '%v' is not authorized", [header]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# max_age_in_seconds exceeds the cap
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    svc := cors_service_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    rule := terraLib.getArray(block.cors_rule)[ridx]
    rule.max_age_in_seconds > max_authorized_age
    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].%s.cors_rule[%d].max_age_in_seconds", [name, svc, ridx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("max_age_in_seconds must be <= %d", [max_authorized_age]),
        "keyActualValue": sprintf("max_age_in_seconds is %d (exceeds cap)", [rule.max_age_in_seconds]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
