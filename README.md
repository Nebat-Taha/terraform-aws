# Multi-Region AWS Infrastructure with Terraform and GitHub Actions

Infrastructure-as-code project for provisioning and managing AWS resources across **US East (N. Virginia), Europe (Frankfurt), and Asia Pacific (Sydney)**. The repository combines reusable Terraform modules, independently managed regional configurations, and GitHub Actions workflows for deployment, drift checks, and teardown. This is a portfolio demonstration of infrastructure engineering practices.

The focus is on **repeatable infrastructure, regional isolation, reusable components, security checks, and controlled changes** rather than deploying a complete multi-region application or automated failover solution.

## Architecture

```text
GitHub Actions (OIDC → AWS IAM role)
       │
       ├── Global Terraform root (us-east-1 provider)
       │     ├── IAM users, policies and access keys
       │     └── AWS Secrets Manager example
       │
       └── Regional Terraform roots (GitHub Actions matrix)
             ├── us-east-1       → VPC, subnets, routes, SG, key pair, EC2
             ├── eu-central-1    → VPC, subnets, routes, SG, key pair
             └── ap-southeast-2  → VPC, subnets, routes, SG, key pair

Each root → separate S3 Terraform state object + DynamoDB locking table
Shared components → terraform/modules/
```

## Engineering decisions

| Decision | Implementation and rationale |
| --- | --- |
| **Reusable modules** | Network, security group, key pair, EC2, IAM user, IAM policy, and Secrets Manager resources are encapsulated under `terraform/modules/` and referenced using relative module paths. This avoids duplicating resource definitions across regional roots. |
| **Regional isolation** | Each region has its own provider configuration, variables, backend state key, and Terraform root. Regional plans can be evaluated independently. |
| **Distinct address spaces** | Region-specific VPC/subnet CIDRs are configured in each regional `terraform.tfvars`, avoiding overlapping networks in the current design. |
| **Centralized remote state** | Terraform backends use an S3 bucket in `us-east-1`, encrypted state objects, distinct state keys, and a DynamoDB locking table. The bucket and table must exist before initialization. |
| **Keyless CI/CD authentication:** | GitHub Actions uses OpenID Connect (OIDC) to assume an AWS IAM role, eliminating the need to store long-lived AWS access keys. Terraform provisions and manages infrastructure through AWS APIs using IAM permissions. Instance-level access mechanisms are configured independently according to workload requirements.|
| **Controlled deployment** | Separate plan and apply jobs save and download plan artifacts. Apply jobs reference GitHub Environments (`test-global` and `test-<region>`) that can enforce reviewer approval when configured in repository settings. |
| **Regional planning and approvals** | A matrix generates plans for all three regions; `fail-fast: false` allows other plan jobs to finish if one fails. The apply stage depends on the complete plan matrix, and each regional apply job uses its own GitHub Environment approval gate, supporting region-specific reviewers and approval history when protection rules are configured. |
| **Configurable workflow triggers** | Deployment workflows currently support manual dispatch and include commented push-to-`main` triggers for optional automation. Destroy workflows are manually triggered and require the exact confirmation text `destroy`; drift workflows support manual checks and have commented scheduled triggers. |
| **Terraform drift**| checks run through GitHub Actions, with support for manual execution and optional scheduling. Detected changes are reported in the workflow logs and intentionally marked as workflow failures to leverage GitHub's native failure notifications.|

## Repository structure

```text
 │
 ├──.github/workflows/
 │   ├──oidc-test.yml
 │   ├──terraform-global-deploy.yml
 │   ├──terraform-global-destroy.yml
 │   ├──terraform-global-drift-detection.yml
 │   ├──terraform-regions-deploy.yml
 │   ├──terraform-regions-destroy.yml
 │   └── terraform-regions-drift-detection.yml
 ├──terraform/
 │   ├──global/                 
 │   ├──regions/
 │       ├──us-east-1/
 |           ├──backend.tf 
 |           ├──main.tf
 |           ├──terraform.tfvars
 |           └──variables.tf           
 │       ├──eu-central-1/
 |           ├──backend.tf 
 |           ├──main.tf
 |           ├──terraform.tfvars
 |           └──variables.tf         
 │       └──ap-southeast-2/
 |           ├──backend.tf 
 |           ├──main.tf
 |           ├──terraform.tfvars
 |           └──variables.tf         
 │   └── modules/
 |        ├──ec2/
 |        ├──iam_policy/
 |        ├──iam_user/
 |        ├──keypair/
 |        ├──network/
 |        ├──secretsmanager/
 |        └──security_group/
```

## Deployment workflow

1. Start **Multi-Region Terraform Deployment** manually in GitHub Actions, or enable its commented push-to-`main` trigger for automated runs.
2. For each configured region, the plan job initializes Terraform, checks formatting, validates the configuration, runs TFLint, and saves a binary `tfplan` artifact.
3. After all plan jobs succeed, each regional apply job downloads its region-specific plan. Its GitHub Environment approval gate must be satisfied before changes are applied, according to the configured environment protection rules.
4. Run the regional or global drift-detection workflows to inspect Terraform plan output in GitHub Actions. Manual dispatch is enabled; daily cron triggers are included as comments for optional scheduling. GitHub may notify users of failed workflow runs according to their notification settings.
5. Use separate manually triggered destroy workflows to tear down temporary infrastructure when it is no longer needed, for example after testing or before a period of inactivity to reduce costs. The user must enter the exact confirmation text `destroy` in the GitHub Actions UI; this is a confirmation input, not a second-person review approval.

## Deployment Prerequisites

Before executing the Terraform workflows:

1. Configure the Terraform remote backend, including the S3 state bucket and DynamoDB locking table used by the project.
2. Configure the AWS IAM role and GitHub Actions OIDC trust relationship to enable keyless authentication.
3. Configure the appropriate Terraform root modules and input variables for the infrastructure required in each target region.
4. Configure GitHub Environments and their required reviewers for regional deployment approvals.

Regional infrastructure is defined and managed through Terraform. Each region can provision a different combination of AWS resources based on its requirements; identical infrastructure across regions is not required.

The GitHub Actions workflows automate Terraform initialization, validation, planning, and deployment according to their configured triggers and approval gates.

## IaC checks and drift visibility

Deployment workflows include formatting, validation, and TFLint checks. tfsec and Checkov steps have been tested and are present as commented steps in the attached snapshot; enable them to run security checks in CI. For enforcement, retain each scanner's normal failure behavior. Where supported, optional soft-fail settings allow findings to be reported without blocking the workflow; the exact setting and effect depend on the tool or GitHub Action version. The regional Checkov example includes a commented `soft_fail: true` option, which should remain disabled when blocking findings is intended.

The drift workflows run Terraform plans and show their output directly in GitHub Actions. Their scheduled triggers are currently commented out to avoid unnecessary recurring runs in this demonstration. No separate alerting service is part of this project; GitHub's own workflow notifications depend on individual user settings.

**Current drift-reporting detail:** The workflow uses `terraform plan -detailed-exitcode` with `continue-on-error: true`, but later steps test `steps.plan_drift.outputs.exitcode`, which the plan step does not set. The reporting conditions therefore do not reliably distinguish exit codes 0, 1, and 2. Capture the exit code explicitly if separate *drift detected*, *no change*, and *plan error* messages are desired. The Terraform plan output remains available in the workflow log.


## Related architecture studies

Broader application, data, and resilience trade-offs are documented separately to keep this README focused on the Terraform implementation:

- [Global Architecture Evolution](https://nebat-taha.github.io/arch-global-evolution.html)
- [Disaster Recovery Strategy](https://nebat-taha.github.io/arch-disaster-recovery.html)
- [Terraform project portfolio overview](https://nebat-taha.github.io/project-terraform.html)

These pages provide architectural context, not a claim that their proposed components are deployed by this repository.
