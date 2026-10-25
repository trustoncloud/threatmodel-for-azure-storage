package wiz

# --- Configuration ---
# Full resource IDs of the subnets a storage account's virtual network rules
# may name. Add your own alongside; matching ignores case.
authorized_subnet_ids := {
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.Network/virtualNetworks/example-vnet/subnets/example-app-subnet"
}

# --- Logic ---
default result := "pass"

authorized_lower := {lower(s) | s := authorized_subnet_ids[_]}

vnet_rules := rules {
    acls := object.get(object.get(input, "properties", {}), "networkAcls", {})
    rules := object.get(acls, "virtualNetworkRules", [])
    is_array(rules)
} else := []

unauthorized_subnets := {id |
    rule := vnet_rules[_]
    id := object.get(rule, "id", "")
    is_string(id)
    id != ""
    not authorized_lower[lower(id)]
}

result := "skip" {
    not input.name
} else := "skip" {
    count(vnet_rules) == 0
} else := "fail" {
    count(unauthorized_subnets) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("Virtual network rules name unauthorized subnets: %v", [unauthorized_subnets]) {
    count(unauthorized_subnets) > 0
} else := sprintf("%v virtual network rule(s), all authorized", [count(vnet_rules)])

expectedConfiguration := "Every virtual network rule names an authorized subnet"
