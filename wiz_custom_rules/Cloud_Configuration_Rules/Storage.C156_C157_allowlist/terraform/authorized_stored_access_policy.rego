package wiz

import data.generic.terraform as terraLib

# --- Configuration ---
# Stored access policy identifiers you approve on file shares and tables.
authorized_access_policy_ids := {"examplereadonly"}

# Permission letters a stored access policy may grant: r (read), a (add),
# c (create), u (update), w (write), d (delete), l (list), p (process).
authorized_access_policy_permissions := {"r", "l"}

# --- Helpers ---
# File shares and tables carry stored access policies as acl blocks;
# containers and queues have no Terraform argument for them.
acl_resource_types := {"azurerm_storage_share", "azurerm_storage_table"}

unauthorized_permissions(perms) := {p |
    is_string(perms)
    p := split(perms, "")[_]
    not authorized_access_policy_permissions[p]
}

# --- Logic ---
# Finding: a stored access policy whose identifier is not authorized.
WizPolicy[result] {
    document := input.document[i]
    rtype := acl_resource_types[_]
    resource := document.resource[rtype][name]
    acl := terraLib.getArray(object.get(resource, "acl", []))[_]
    not authorized_access_policy_ids[acl.id]

    result := {
        "documentId": document.id,
        "resourceType": rtype,
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("%s[%s].acl", [rtype, name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("stored access policy id is one of %v", [authorized_access_policy_ids]),
        "keyActualValue": sprintf("stored access policy id is %v", [acl.id]),
        "resourceTags": {},
    }
}

# Finding: a stored access policy granting an unauthorized permission.
WizPolicy[result] {
    document := input.document[i]
    rtype := acl_resource_types[_]
    resource := document.resource[rtype][name]
    acl := terraLib.getArray(object.get(resource, "acl", []))[_]
    policy := terraLib.getArray(object.get(acl, "access_policy", []))[_]
    extra := unauthorized_permissions(policy.permissions)
    count(extra) > 0

    result := {
        "documentId": document.id,
        "resourceType": rtype,
        "resourceName": terraLib.get_resource_name(resource, name),
        "searchKey": sprintf("%s[%s].acl.access_policy.permissions", [rtype, name]),
        "issueType": "IncorrectValue",
        "keyExpectedValue": sprintf("permissions use only %v", [authorized_access_policy_permissions]),
        "keyActualValue": sprintf("stored access policy %v grants %v", [acl.id, extra]),
        "resourceTags": {},
    }
}
