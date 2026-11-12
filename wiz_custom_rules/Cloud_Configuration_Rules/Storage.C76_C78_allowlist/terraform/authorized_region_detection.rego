package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Authorized Azure regions (lowercase). A geo-redundant account also holds data
# in its paired region, so list both regions of each pair you use.
allowed_regions := {"eastus", "westus", "westeurope", "northeurope", "australiaeast", "australiasoutheast"}

# --- Helpers ---
# Azure accepts a region's name ("eastus") or display name ("East US"):
# compare lowercased with spaces removed.
tf_region_key(v) := replace(lower(v), " ", "")

# A location that copies a resource group's location
# ("${azurerm_resource_group.<name>.location}") names that resource group.
tf_rg_location_ref(v) := rg {
    is_string(v)
    m := regex.find_all_string_submatch_n(`^\$\{azurerm_resource_group\.([A-Za-z0-9_-]+)(?:\[[^\]]*\])?\.location\}$`, v, 1)
    rg := m[0][1]
}

# The account's location: the literal value, or the literal location of the
# resource group it copies when that group is declared in the same file.
tf_account_location(document, resource) := loc {
    rg := tf_rg_location_ref(resource.location)
    loc := document.resource.azurerm_resource_group[rg].location
    is_string(loc)
    not tocm_tf_unresolved(loc)
} else := resource.location

# --- Logic ---
# location is a required argument. A value this scan cannot resolve is never
# approved.
WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "location")
    loc := tf_account_location(document, resource)
    not tocm_tf_unresolved(loc)
    allowed_keys := {tf_region_key(r) | r := allowed_regions[_]}
    not allowed_keys[tf_region_key(loc)]

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].location", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("location must be one of the authorized regions: %v", [allowed_regions]),
        "keyActualValue": sprintf("location is '%v' (not authorized)", [loc]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

WizPolicy[result] {
    document := input.document[i]
    resource := document.resource.azurerm_storage_account[name]
    terraLib.validKey(resource, "location")
    loc := tf_account_location(document, resource)
    tocm_tf_unresolved(loc)

    result := {
        "documentId": document.id,
        "resourceType": "azurerm_storage_account",
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("azurerm_storage_account[%s].location", [name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("location must be one of the authorized regions: %v", [allowed_regions]),
        "keyActualValue": sprintf("location '%v' is not resolved by this source scan", [loc]),
        "resourceTags": terraLib.get_resource_tags(resource),
    }
}

# --- Matching helpers ---
# --- toc-match begin: tf v1 ---
# A Terraform value that is still an unresolved reference ("${...}"). Treat
# it as unknown: never compare it with an allowlist as a string.
tocm_tf_unresolved(v) {
    is_string(v)
    contains(v, "${")
}
# --- toc-match end: tf v1 ---
