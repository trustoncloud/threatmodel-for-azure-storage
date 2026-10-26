package wiz

# --- Configuration ---
# Best practice is to list the most restrictive CORS rules first.
allowed_origins := {"https://myapp.contoso.com", "https://api.contoso.com"}
allowed_methods := {"GET", "POST", "PUT"}
allowed_headers := {"Content-Type", "x-ms-blob-content-type"}
allowed_exposed_headers := {"x-ms-request-id"}
max_authorized_age := 200

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

# --- Logic ---
default result := "pass"

# Rule 1: Unauthorized Origin
violations[msg] {
    rule := cors_rule[_]
    origin := rule.allowedOrigins[_]
    not allowed_origins[origin]
    msg := sprintf("Unauthorized origin '%v' found", [origin])
}

# Rule 2: Unauthorized Method
violations[msg] {
    rule := cors_rule[_]
    method := rule.allowedMethods[_]
    not allowed_methods[method]
    msg := sprintf("Unauthorized method '%v' found", [method])
}

# Rule 3: Unauthorized Request Header
violations[msg] {
    rule := cors_rule[_]
    header := rule.allowedHeaders[_]
    not allowed_headers[header]
    msg := sprintf("Unauthorized request header '%v' found", [header])
}

# Rule 4: Unauthorized Exposed Header
violations[msg] {
    rule := cors_rule[_]
    header := rule.exposedHeaders[_]
    not allowed_exposed_headers[header]
    msg := sprintf("Unauthorized exposed header '%v' found", [header])
}

# Rule 5: MaxAge Violation
violations[msg] {
    rule := cors_rule[_]
    rule.maxAgeInSeconds > max_authorized_age
    msg := sprintf("MaxAge %v exceeds limit of %v", [rule.maxAgeInSeconds, max_authorized_age])
}

result := "skip" {
    count(cors_rule) == 0
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("CORS Violations found: %v", [violations])
expectedConfiguration := "Every CORS rule must strictly use authorized origins, methods, headers, and MaxAge."
