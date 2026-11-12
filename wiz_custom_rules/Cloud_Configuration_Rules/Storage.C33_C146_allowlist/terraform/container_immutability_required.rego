package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
required_containers := {"examplefinancearchive", "exampleauditlogs"}

# --- Helpers ---
# True if an immutability policy in this document references exactly this
# container: "${azurerm_storage_container.<name>.id}" (or resource_manager_id).
tf_has_immutability_policy(document, name) {
    policy := document.resource.azurerm_storage_container_immutability_policy[_]
    ref := object.get(policy, "storage_container_resource_manager_id", "")
    is_string(ref)
    m := regex.find_all_string_submatch_n(`^\$\{\s*azurerm_storage_container\.([A-Za-z0-9_-]+)(?:\[[^\]]*\])?\.(id|resource_manager_id)\s*\}$`, ref, 1)
    m[0][1] == name
}

# --- Logic ---
# Required containers must have an immutability policy. Fire when a required
# container has no associated azurerm_storage_container_immutability_policy.
WizPolicy[result] {
    document := input.document[i]
    container := document.resource.azurerm_storage_container[name]
    required_containers[container.name]
    not tf_has_immutability_policy(document, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_container",
        "resourceName": terraLib.get_resource_name(container, name),
        "searchKey": sprintf("azurerm_storage_container[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "required container must have an azurerm_storage_container_immutability_policy",
        "keyActualValue": sprintf("required container '%v' has no immutability policy", [container.name]),
        "resourceTags": terraLib.get_resource_tags(container),
    }
}
