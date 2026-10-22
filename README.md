# Multi-Region AWS Infrastructure with Terraform and GitHub Actions

Infrastructure-as-code project for provisioning and managing AWS resources across **US East (N. Virginia), Europe (Frankfurt), and Asia Pacific (Sydney)**. The repository combines reusable Terraform modules, independently managed regional configurations, and GitHub Actions workflows for deployment, drift checks, and teardown. This is a portfolio demonstration of infrastructure engineering practices.

The focus is on **repeatable infrastructure, regional isolation, reusable components, security checks, and controlled changes** rather than deploying a complete multi-region application or automated failover solution.

## Architecture

```text
GitHub Actions (OIDC → AWS IAM role)
       │
       |
       ├──Modules (Reusable)
       |
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
| **Reusable modules** | Infrastructure resources are defined in reusable modules under terraform/modules/ and referenced through relative paths from regional Terraform configurations. This eliminates repetitive resource definitions and promotes consistency across deployments. By maintaining common configurations in centralized modules, resources can share standardized settings and security controls across regions, reducing configuration inconsistencies, and potential security gaps while allowing region-specific customization where required. |
|**Separate Global and Regional Infrastructure** | Terraform configurations are organized according to AWS resource scope. Account-level resources, such as IAM users, roles, and policies, are managed through a centralized global configuration, while regional resources, such as VPCs and EC2 instances, are provisioned independently in their respective AWS regions. This separation aligns with AWS resource boundaries,and enables independent management of global and regional infrastructure.|
| **Regional isolation** | Each region has its own provider configuration, variables, backend state with dynamo db, and Terraform root. This keeps regional changes and state operations separated. |
| **Distinct address spaces** | Region-specific VPC/subnet CIDRs are configured in each regional `terraform.tfvars`, avoiding overlapping networks in the current design. |
| **Keyless CI/CD authentication:** | GitHub Actions uses OpenID Connect (OIDC) to assume an AWS IAM role, eliminating the need to store long-lived AWS access keys. Terraform provisions and manages infrastructure through AWS APIs using IAM permissions.|
| **Controlled deployment** | Separate plan and apply jobs save and download plan artifacts. Apply jobs reference GitHub Environments (`test-global` and `test-<region>`) that can enforce reviewer approval when configured in repository settings. |
| **Regional planning and approvals** | A matrix generates plans for all three regions; `fail-fast: false` allows other plan jobs to finish if one fails. The apply stage depends on the complete plan matrix, and each regional apply job uses its own GitHub Environment approval gate, supporting region-specific reviewers and approval history when protection rules are configured. |
| **Configurable workflow triggers** | Deployment workflows currently support manual dispatch and include commented push-to-`main` triggers for optional automation. Destroy workflows are manually triggered and require the exact confirmation text `destroy`; drift workflows support manual checks and have commented scheduled triggers. |
| **Reusable execution workflows**| GitHub Actions automates initialization, checks, planning, applying, drift checks, and controlled teardown.|
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


## Drift detection
Dedicated global and regional workflows run Terraform plans with -detailed-exitcode to compare the configured infrastructure against the resources Terraform manages. The regional workflow uses a matrix to check the configured regions. Plan output is available in the GitHub Actions run logs.

The intended reporting distinguishes:
Terraform exit code	Meaning
0	No changes detected
1	Terraform plan encountered an error
2	Changes detected


Detected changes can intentionally be surfaced as failed GitHub Actions runs so the result is visible through the Actions interface and eligible for GitHub's native workflow-failure notifications, according to each user's notification settings.

Drift checks are manually dispatchable. Optional scheduled triggers are included as commented configuration and can be enabled when recurring checks are desired. These checks concern Terraform-managed resources; unrelated resources created outside Terraform and not imported into its state are not part of the comparison.

## Related architecture studies

Broader application, data, and resilience trade-offs are documented separately to keep this README focused on the Terraform implementation:

- [Global Architecture Evolution](https://nebat-taha.github.io/arch-global-evolution.html)
- [Disaster Recovery Strategy](https://nebat-taha.github.io/arch-disaster-recovery.html)
- [Terraform project portfolio overview](https://nebat-taha.github.io/project-terraform.html)

These pages provide architectural context, not a claim that their proposed components are deployed by this repository.
