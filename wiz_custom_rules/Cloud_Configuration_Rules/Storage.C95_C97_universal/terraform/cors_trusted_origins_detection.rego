package wiz

import data.generic.terraform as terraLib

# CORS rules live in three per-service blocks on azurerm_storage_account.
cors_service_blocks := ["blob_properties", "queue_properties", "share_properties"]

# --- Logic ---
# Universal: CORS must be disabled entirely. Fire on any cors_rule present in
# any service block.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    svc := cors_service_blocks[_]
    block := terraLib.getValueArrayOrObject(object.get(resource, svc, {}))
    # cors_rule is repeatable: normalize object-or-list to a list.
    rule := terraLib.getArray(block.cors_rule)[ridx]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].%s.cors_rule[%d]", [name, svc, ridx]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "no cors_rule may be defined (CORS must be disabled for all storage services)",
        "keyActualValue": sprintf("%s.cors_rule[%d] is defined", [svc, ridx]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}
