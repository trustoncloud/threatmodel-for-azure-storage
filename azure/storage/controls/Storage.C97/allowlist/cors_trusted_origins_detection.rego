package wiz

# --- Configuration ---
# Note: In general the best practice is to list the most restrictive rules first.
# Reference: https://learn.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services#:~:text=Expand%20table-,Method,the%20best%20practice%20is%20to%20list%20the%20most%20restrictive%20rules%20first.,-Understanding%20how%20the
allowed_origins := {"https://myapp.contoso.com", "https://api.contoso.com"}
allowed_methods := {"GET", "POST", "PUT"}
allowed_headers := {"Content-Type", "x-ms-blob-content-type"}
allowed_exposed_headers := {"x-ms-request-id"}
max_authorized_age := 200

# --- Logic ---
default result := "pass"

cors_rules := input.properties.cors.corsRules

has_cors_rules {
    count(cors_rules) > 0
}

# Rule 1: Unauthorized Origin
violations[msg] {
    rule := cors_rules[_]
    origin := rule.allowedOrigins[_]
    not allowed_origins[origin]
    msg := sprintf("Unauthorized origin '%v' found", [origin])
}

# Rule 2: Unauthorized Method
violations[msg] {
    rule := cors_rules[_]
    method := rule.allowedMethods[_]
    not allowed_methods[method]
    msg := sprintf("Unauthorized method '%v' found", [method])
}

# Rule 3: Unauthorized Request Header
violations[msg] {
    rule := cors_rules[_]
    header := rule.allowedHeaders[_]
    not allowed_headers[header]
    msg := sprintf("Unauthorized request header '%v' found", [header])
}

# Rule 4: Unauthorized Exposed Header
violations[msg] {
    rule := cors_rules[_]
    header := rule.exposedHeaders[_]
    not allowed_exposed_headers[header]
    msg := sprintf("Unauthorized exposed header '%v' found", [header])
}

# Rule 5: MaxAge Violation
violations[msg] {
    rule := cors_rules[_]
    rule.maxAgeInSeconds > max_authorized_age
    msg := sprintf("MaxAge %v exceeds limit of %v", [rule.maxAgeInSeconds, max_authorized_age])
}

# Final Logic Chain
result := "skip" {
    not input.properties.cors.corsRules
} else := "fail" {
    count(violations) > 0
}

# --- Metadata ---
currentConfiguration := sprintf("CORS Violations found: %v", [violations])
expectedConfiguration := "Every CORS rule must strictly use authorized origins, methods, headers, and MaxAge."