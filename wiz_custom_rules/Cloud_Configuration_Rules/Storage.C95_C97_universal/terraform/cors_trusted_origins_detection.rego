package wiz

import data.generic.terraform as terraLib

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
    terraLib.getArray(block.cors_rule)[ridx]
    entry := {
        "type": "azurerm_storage_account",
        "name": name,
        "resource": resource,
        "path": sprintf("%s.cors_rule[%d]", [svc, ridx]),
    }
} | {entry |
    rtype := tf_standalone_cors_types[_]
    resource := document.resource[rtype][name]
    terraLib.getArray(resource.cors_rule)[ridx]
    entry := {
        "type": rtype,
        "name": name,
        "resource": resource,
        "path": sprintf("cors_rule[%d]", [ridx]),
    }
}

# --- Logic ---
# Universal: CORS is disabled for the blob, file, queue and table services.
# Fire on any cors_rule.
WizPolicy[result] {
    document := input.document[i]
    entry := tf_cors_rules(document)[_]

    result := {
        "documentId": document.id,
        "resourceType": entry.type,
        "resourceName": terraLib.get_resource_name(entry.resource, entry.name),
        "searchKey": sprintf("%s[%s].%s", [entry.type, entry.name, entry.path]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "no cors_rule may be defined (CORS must be disabled for all storage services)",
        "keyActualValue": sprintf("%s is defined", [entry.path]),
        "resourceTags": terraLib.get_resource_tags(entry.resource),
    }
}
