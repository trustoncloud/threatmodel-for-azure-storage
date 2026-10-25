# ThreatModel for Azure Storage
A library of all the attack scenarios on Azure Storage, and how to mitigate them following a risk-based approach 

## Intro
See the blog: https://trustoncloud.com/the-last-azure-security-document-that-well-ever-need/

## Interactive version
Find an interactive version of this content: https://demo.app.trustoncloud.com/threatmodel/azure/storage

## Wiz Cloud Configuration Rules
[`wiz_custom_rules/`](wiz_custom_rules/) holds custom Wiz Cloud Configuration Rules (OPA Rego) for the assurance controls in this ThreatModel. Each rule checks deployed storage accounts and their services, infrastructure as code in Terraform, or both, and the folder includes the Terraform to deploy the rules to your Wiz tenant. Start with its [README](wiz_custom_rules/README.md); the [mapping CSV](wiz_custom_rules/Azure%20Storage%20Controls%20and%20Wiz%20Mapping.csv) shows which controls Wiz built-in rules already cover.

## Contact
Email [contact@trustoncloud.com](mailto:contact@trustoncloud.com) or use GitHub issues
