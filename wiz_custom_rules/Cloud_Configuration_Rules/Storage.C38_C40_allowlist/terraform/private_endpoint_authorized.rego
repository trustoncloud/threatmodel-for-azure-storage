package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
storage_subresources := {"blob", "file", "queue", "table", "dfs", "web"}

# Authorized private DNS zones a storage private endpoint may integrate with.
authorized_dns_zones := {
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.web.core.windows.net",
}

# --- Helpers ---
is_storage_pe(pe) {
    psc := terraLib.getValueArrayOrObject(pe.private_service_connection)
    storage_subresources[psc.subresource_names[_]]
}

# True if the endpoint's private_dns_zone_group references a private DNS zone
# (declared in this document) whose name is authorized.
has_authorized_dns_zone(document, pe) {
    pdzg := terraLib.getValueArrayOrObject(pe.private_dns_zone_group)
    zone_ref := pdzg.private_dns_zone_ids[_]
    zone := document.resource.azurerm_private_dns_zone[zname]
    indexof(zone_ref, zname) != -1
    authorized_dns_zones[zone.name]
}

# --- Logic ---
# Allowlist: a storage private endpoint must integrate with an authorized
# private DNS zone. Fire when it has no authorized zone (missing zone group,
# or the referenced zone is not in the authorized set).
WizPolicy[result] {
    document := input.document[i]
    pe := document.resource.azurerm_private_endpoint[name]
    is_storage_pe(pe)
    not has_authorized_dns_zone(document, pe)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_private_endpoint",
        "resourceName": terraLib.get_resource_name(pe, name),
        "searchKey": sprintf("azurerm_private_endpoint[%s].private_dns_zone_group", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("storage private endpoint must reference an authorized private DNS zone: %v", [authorized_dns_zones]),
        "keyActualValue": sprintf("private endpoint '%s' does not reference an authorized private DNS zone", [name]),
        "resourceTags": terraLib.get_resource_tags(pe),
    }
}
