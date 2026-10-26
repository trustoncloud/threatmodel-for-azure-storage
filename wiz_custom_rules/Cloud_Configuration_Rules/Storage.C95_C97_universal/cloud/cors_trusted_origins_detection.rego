package wiz

default result := "pass"

# CORS settings live under the per-service objects Wiz aggregates onto the
# storage account, one per blob/file/queue/table service.
storage_services := {
    "AccountStorageServicesBlobServiceProperties",
    "AccountStorageServicesFileServiceProperties",
    "AccountStorageServicesQueueServiceProperties",
    "AccountStorageServicesTableServiceProperties",
}

cors_rule[rule] {
    svc := storage_services[_]
    rule := input[svc].properties.cors.corsRules[_]
}

has_cors_rules {
    count(cors_rule) > 0
}

result := "skip" {
    not input.properties
} else := "fail" {
    has_cors_rules
}

currentConfiguration := sprintf("%v CORS rule(s) configured across the blob, file, queue and table services", [count(cors_rule)]) {
    has_cors_rules
} else := "No CORS rules configured"
expectedConfiguration := "CORS must be disabled entirely for all storage services (Universal mode)."
