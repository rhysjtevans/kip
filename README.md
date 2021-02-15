# Keybase OpenID Connect Provider
NOTE: Still a work in progress but hopefully will give you what you need to get up and running. It is functional there's a to-do list before I'd consider this version `1.0.0`.
This has dropped down my priority list but if anyone is considering adopting it, star the project or create an issue and I'll move it up the priority list.
 
## Intro
KIP is an AWS Serverless-based Keybase Identity Provider that can be used to extend on the great work Keybase are doing and provide an agnostic interface via OpenID Connect to cryptographically link corporate identities (Google, Azure Active Directory, OKTA, ADFS) to other online identities via Keybase accounts.

## Why?
The goal is to improve collaboration and trust of online third-party accounts between corporate parties leveraging Keybase and it's cryptographic certainty.

The use-case I had to build this was to provide trust that online GitHub accounts were accounts of engineers of trusted corporate parties to work on GitHub projects.

This is also a building block to a follow up project I am planning - a Keybase Chat/Helper bot that could 
- Generate secure OpenVPN client configuration and send it to Keybase user (after validating corporate identity)
- Securely resetting/issuing credentials


## User Experience
1) User attempts to verify/prove their corporate identity through Keybase Web UI
2) User is redirected to the corporate identity provider (e.g. Azure AD)
3) User logs into corporate Identity Provider
3) User is redirected to a landing site that then verifies the OIDC token and stores the validation token in DynamoDB
4) Keybase will periodically poll the service to verify the account is genuine and not been revoked

More info on [Keybase Integration Proof flow]([Keybase](https://keybase.io/docs/proof_integration_guide))
## Getting Started
NOTE: Current state is WIP and YMMV - e.g. Terraform has recently upgraded and thus TF files may need updating (versioning wasn't implemented at the time! D'Oh!)
This project will spin up
 - AWS API Gateway
 - AWS Lambda
 - AWS DynamoDB Tables
 - Cloudflare DNS
 - Azure AD App (On the ToDo list)

You will need
 - Terraform
 - Docker
 - Cloudflare
 - AWS account credentials in `~/.aws/credentials` with a profile name of `keybase`
 - Azure AD account credentials - `az login`
### Prerequisites

#### Docker
Unfortunately, Docker is the only way (working on a Mac) I could package the python venv to work with AWS Lambda. If anyone else has achieved this do let me know - would be great to hear!
Caveat is I'm not a python person so if there's a better way - I can't wait to see the [Pull Request](https://github.com/pull_request_uri)


## ToDo
Want to help out? Here's what's I want to get done or feel free to contribute in other ways
 - Documentation
  - Instructions
 - Fine tune API Gateway
 - Terratest
   - Requests
   - Responses
   - Caching
 - DynamoDB
   - Secondary indexes
   - TTL on validation table
 - WAF
 - IAM role policies
 - Find a way to repackage `oauth_validation` lambda cross-platform - need a python expert 😄
 - Move DNS to Route53?
 - Define a provisioning policy in documentation
   - Azure AD: Create Azure AD app
   - AWS: Create all infrastructure
 - Add a terraform file to provision an Azure AD app
 - Standardise API Gateway body responses
 - Some bug fixes along the way
 - Better documentation
 - Better code
