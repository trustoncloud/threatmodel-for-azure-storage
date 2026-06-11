package wiz

import data.generic.terraform as terraLib

# --- Helpers ---
has_immutability_policy(document, container, name) {
    policy := document.resource.azurerm_storage_container_immutability_policy[pName]
    terraLib.associatedResources(container, policy, name, pName, null, "storage_container_resource_manager_id")
}

# --- Logic ---
# Universal: every container must have an immutability policy. Fire when a
# container has no associated azurerm_storage_container_immutability_policy.
WizPolicy[result] {
    document := input.document[i]
    container := document.resource.azurerm_storage_container[name]
    not has_immutability_policy(document, container, name)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_container",
        "resourceName": terraLib.get_resource_name(container, name),
        "searchKey": sprintf("azurerm_storage_container[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "every container must have an azurerm_storage_container_immutability_policy",
        "keyActualValue": sprintf("container '%v' has no immutability policy", [container.name]),
        "resourceTags": terraLib.get_resource_tags(container),
    }
}
