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
# The parts of a whole-value reference such as "${azurerm_storage_account.sa.id}".
tf_ref_parts(v) := parts {
    is_string(v)
    m := regex.find_all_string_submatch_n(`^\$\{([^${}]+)\}$`, trim_space(v), 1)
    count(m) == 1
    parts := [p | q := split(m[0][1], ".")[_]; p := regex.replace(q, `\[[^\]]*\]$`, "")]
}

# The segments of a literal Azure resource ID, lowercased.
tf_id_segments(v) := split(tocm_azure_id_norm(v), "/")

# A literal ID of the form /subscriptions/<s>/resourceGroups/<rg>/providers/<ns>/<type>/<name>.
tf_id_is(v, ns, type) {
    seg := tf_id_segments(v)
    count(seg) == 9
    seg[3] == "resourcegroups"
    seg[5] == "providers"
    seg[6] == ns
    seg[7] == type
}

tf_psc(pe) := terraLib.getValueArrayOrObject(object.get(pe, "private_service_connection", {}))

tf_target(pe) := object.get(tf_psc(pe), "private_connection_resource_id", "")

tf_target_is_storage(pe) {
    parts := tf_ref_parts(tf_target(pe))
    count(parts) == 3
    parts[0] == "azurerm_storage_account"
    parts[2] == "id"
}

tf_target_is_storage(pe) {
    parts := tf_ref_parts(tf_target(pe))
    count(parts) == 4
    parts[0] == "data"
    parts[1] == "azurerm_storage_account"
    parts[3] == "id"
}

tf_target_is_storage(pe) {
    tf_id_is(tf_target(pe), "microsoft.storage", "storageaccounts")
}

# The target names a resource of a known type: a literal ID or a resource reference.
tf_target_known(pe) {
    tocm_azure_id_norm(tf_target(pe))
}

tf_target_known(pe) {
    parts := tf_ref_parts(tf_target(pe))
    regex.match(`^azurerm_[a-z0-9_]+$`, parts[0])
}

tf_target_known(pe) {
    parts := tf_ref_parts(tf_target(pe))
    parts[0] == "data"
    regex.match(`^azurerm_[a-z0-9_]+$`, parts[1])
}

# A storage private endpoint: its target is a storage account, or its target is
# not resolved by this source scan and it asks for a storage sub-resource.
tf_is_storage_pe(pe) {
    tf_target_is_storage(pe)
}

tf_is_storage_pe(pe) {
    not tf_target_known(pe)
    storage_subresources[lower(tf_psc(pe).subresource_names[_])]
}

tf_manual_connection(pe) {
    v := object.get(tf_psc(pe), "is_manual_connection", false)
    v == true
} else {
    object.get(tf_psc(pe), "is_manual_connection", false) == "true"
}

# A zone in the private_dns_zone_group: a zone declared in this document, or a literal zone ID.
tf_authorized_zone(document, zone_ref) {
    parts := tf_ref_parts(zone_ref)
    count(parts) == 3
    parts[0] == "azurerm_private_dns_zone"
    parts[2] == "id"
    zone := document.resource.azurerm_private_dns_zone[parts[1]]
    authorized_dns_zones[lower(zone.name)]
}

tf_authorized_zone(_, zone_ref) {
    tf_id_is(zone_ref, "microsoft.network", "privatednszones")
    authorized_dns_zones[tf_id_segments(zone_ref)[8]]
}

tf_has_authorized_dns_zone(document, pe) {
    pdzg := terraLib.getValueArrayOrObject(pe.private_dns_zone_group)
    tf_authorized_zone(document, pdzg.private_dns_zone_ids[_])
}

# --- Logic ---
# Allowlist: a storage private endpoint integrates with an authorized private
# DNS zone, and a manual connection request is reported for review. Endpoint
# identity is checked by the cloud matcher: the source does not show the
# endpoint's subscription.

# Manual connection request: approved later by the storage account owner
WizPolicy[result] {
    document := input.document[i]
    pe := document.resource.azurerm_private_endpoint[name]
    tf_is_storage_pe(pe)
    tf_manual_connection(pe)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_private_endpoint",
        "resourceName": terraLib.get_resource_name(pe, name),
        "searchKey": sprintf("azurerm_private_endpoint[%s].private_service_connection.is_manual_connection", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": "is_manual_connection is false, or the manual connection request is reviewed and approved by the storage account owner",
        "keyActualValue": sprintf("private endpoint '%s' requests a manual connection: it stays Pending until the storage account owner approves it, and this source scan does not see that approval", [name]),
        "resourceTags": terraLib.get_resource_tags(pe),
    }
}

# No authorized private DNS zone
WizPolicy[result] {
    document := input.document[i]
    pe := document.resource.azurerm_private_endpoint[name]
    tf_is_storage_pe(pe)
    not tf_has_authorized_dns_zone(document, pe)

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

# --- Matching helpers ---
# --- toc-match begin: azureid v1 ---
# Azure resource IDs compare case-insensitively, segment by segment.
tocm_azure_id_norm(id) := n {
    is_string(id)
    n := lower(trim_suffix(trim_space(id), "/"))
    startswith(n, "/subscriptions/")
    not contains(n, "//")
}

tocm_azure_id_equal(a, b) {
    tocm_azure_id_norm(a) == tocm_azure_id_norm(b)
}

tocm_azure_id_allowed(id, allowed) {
    tocm_azure_id_equal(id, allowed[_])
}
# --- toc-match end: azureid v1 ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
