package wiz

# --- Configuration ---
# Versionless URLs of the customer-managed keys storage accounts may use:
# https://<vault-name>.vault.azure.net/keys/<key-name>. Add your own
# alongside; matching ignores case and any key version.
authorized_key_urls := {
    "https://examplevault.vault.azure.net/keys/examplestoragekey"
}

# --- Logic ---
default result := "pass"

encryption := object.get(object.get(input, "properties", {}), "encryption", {})

uses_customer_managed_key {
    lower(object.get(encryption, "keySource", "")) == "microsoft.keyvault"
}

authorized_lower := {trim_suffix(lower(u), "/") | u := authorized_key_urls[_]}

# Azure reports the key as its vault URI plus key name.
key_url := url {
    kv := object.get(encryption, "keyvaultproperties", {})
    uri := object.get(kv, "keyvaulturi", "")
    name := object.get(kv, "keyname", "")
    is_string(uri)
    is_string(name)
    uri != ""
    name != ""
    url := sprintf("%v/keys/%v", [trim_suffix(lower(uri), "/"), lower(name)])
}

result := "skip" {
    not input.name
} else := "skip" {
    not uses_customer_managed_key
} else := "fail" {
    not key_url
} else := "fail" {
    not authorized_lower[key_url]
}

# --- Metadata ---
currentConfiguration := sprintf("Encrypted with key %v", [key_url]) {
    key_url
} else := "Encrypted with a customer-managed key whose vault URI or name is not reported"

expectedConfiguration := sprintf("Customer-managed key must be one of: %v", [authorized_key_urls])
