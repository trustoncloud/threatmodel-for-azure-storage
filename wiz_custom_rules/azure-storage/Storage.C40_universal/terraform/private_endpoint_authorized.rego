package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Sub-services that identify a private endpoint as targeting Azure Storage.
storage_subresources := {"blob", "file", "queue", "table", "dfs", "web"}

# --- Helpers ---
is_storage_pe(pe) {
    psc := terraLib.getValueArrayOrObject(pe.private_service_connection)
    storage_subresources[psc.subresource_names[_]]
}

# --- Logic ---
# Universal: a private endpoint targeting a storage account must integrate
# with a private DNS zone (private_dns_zone_group), so the storage FQDN
# resolves to the private IP. Fire when the block is absent.
WizPolicy[result] {
    document := input.document[i]
    pe := document.resource.azurerm_private_endpoint[name]
    is_storage_pe(pe)
    not terraLib.validKey(pe, "private_dns_zone_group")

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_private_endpoint",
        "resourceName": terraLib.get_resource_name(pe, name),
        "searchKey": sprintf("azurerm_private_endpoint[%s]", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "storage private endpoint must define a private_dns_zone_group",
        "keyActualValue": sprintf("private endpoint '%s' targets storage but has no private_dns_zone_group", [name]),
        "resourceTags": terraLib.get_resource_tags(pe),
    }
}
