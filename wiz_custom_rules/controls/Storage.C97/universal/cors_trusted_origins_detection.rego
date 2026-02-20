package wiz

default result := "pass"

has_cors_rules {
    count(input.properties.cors.corsRules) > 0
}

result := "skip" {
    not input.properties
} else := "fail" {
    has_cors_rules
}

currentConfiguration := "CORS rules are enabled for this service."
expectedConfiguration := "CORS must be disabled entirely for all storage services (Universal mode)."