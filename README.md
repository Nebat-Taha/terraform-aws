Multi-Region AWS Infrastructure with Terraform and GitHub Actions
Infrastructure-as-code project for provisioning and managing AWS resources across US East (N. Virginia), Europe (Frankfurt), and Asia Pacific (Sydney). The repository combines reusable Terraform modules, independently managed regional configurations, and GitHub Actions workflows for deployment, drift checks, and teardown. This is a portfolio demonstration of infrastructure engineering practices developed in the context of Savi Finance’s global expansion work.

The focus is on repeatable infrastructure, regional isolation, reusable components, security checks, and controlled changes rather than deploying a complete multi-region application or automated failover solution.
Architecture
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
The network module creates a VPC with DNS enabled, an internet gateway, a public application subnet associated with an internet-facing route table, and a separate database subnet without an explicit public route-table association. Both subnets currently use one configured availability zone per region. The database subnet is a network building block; no database instance is provisioned.
Engineering decisions
Decision	Implementation and rationale
Reusable modules	Network, security group, key pair, EC2, IAM user, IAM policy, and Secrets Manager resources are encapsulated under terraform/modules/ and referenced using relative module paths. This avoids duplicating resource definitions across regional roots.
Regional isolation	Each region has its own provider configuration, variables, backend state key, and Terraform root. Regional plans can be evaluated independently.
Distinct address spaces	Region-specific VPC/subnet CIDRs are configured in each regional terraform.tfvars, avoiding overlapping networks in the current design.
Centralized remote state	Terraform backends use an S3 bucket in us-east-1, encrypted state objects, distinct state keys, and a DynamoDB locking table. The bucket and table must exist before initialization.
Short-lived CI credentials	Workflows use GitHub OIDC to assume an AWS role through AWS_ROLE_ARN, avoiding persistent AWS access keys in the CI workflow.
Controlled deployment	Separate plan and apply jobs save and download plan artifacts. Apply jobs reference GitHub Environments (test-global and test-<region>) that can enforce reviewer approval when configured in repository settings.
Regional planning and approvals	A matrix generates plans for all three regions; fail-fast: false allows other plan jobs to finish if one fails. The apply stage depends on the complete plan matrix, and each regional apply job uses its own GitHub Environment approval gate, supporting region-specific reviewers and approval history when protection rules are configured.
Configurable workflow triggers	Deployment workflows currently support manual dispatch and include commented push-to-main triggers for optional automation. Destroy workflows are manually triggered and require the exact confirmation text destroy; drift workflows support manual checks and have commented scheduled triggers.


Repository structure
.github/workflows/
  oidc-test.yml
  terraform-global-deploy.yml
  terraform-global-destroy.yml
  terraform-global-drift-detection.yml
  terraform-regions-deploy.yml
  terraform-regions-destroy.yml
  terraform-regions-drift-detection.yml
terraform/
  global/                 # Account-level IAM and Secrets Manager examples
  regions/
    us-east-1/            # Network, security, key pair, EC2
    eu-central-1/         # Network, security, key pair
    ap-southeast-2/       # Network, security, key pair
  modules/
    ec2/
    iam_policy/
    iam_user/
    keypair/
    network/
    secretsmanager/
    security_group/
Deployment workflow
1. Start Multi-Region Terraform Deployment manually in GitHub Actions, or enable its commented push-to-main trigger for automated runs.
2. For each configured region, the plan job initializes Terraform, checks formatting, validates the configuration, runs TFLint, and saves a binary tfplan artifact.
3. After all plan jobs succeed, each regional apply job downloads its region-specific plan. Its GitHub Environment approval gate must be satisfied before changes are applied, according to the configured environment protection rules.
4. Run the regional or global drift-detection workflows to inspect Terraform plan output in GitHub Actions. Manual dispatch is enabled; daily cron triggers are included as comments for optional scheduling. GitHub may notify users of failed workflow runs according to their notification settings.
5. Use separate manually triggered destroy workflows to tear down temporary infrastructure when it is no longer needed, for example after testing or before a period of inactivity to reduce costs. The user must enter the exact confirmation text destroy in the GitHub Actions UI; this is a confirmation input, not a second-person review approval.
Global resources have their own deployment and lifecycle workflows. Important: The global deployment currently uploads the artifact as tfplan-global but attempts to download tfplan; this mismatch must be fixed before the global apply stage can use the saved plan.
Running a regional configuration locally
Prerequisites: Terraform CLI 1.12.1 or later, AWS credentials with appropriate permissions, and a pre-existing S3 state bucket and DynamoDB locking table. GitHub Actions additionally requires an AWS OIDC trust relationship and the AWS_ROLE_ARN repository secret. The Terraform AWS provider is constrained to ~> 5.0.

From the repository root:
cd terraform/regions/us-east-1
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
# Review the plan before applying:
terraform show tfplan
terraform apply tfplan
To target another region, change the working directory to terraform/regions/eu-central-1 or terraform/regions/ap-southeast-2. Configure the backend bucket/key, regional CIDRs, SSH public key, and permitted SSH CIDRs for your own AWS account before running. The existing backend bucket name is project-specific; do not assume it exists in another account. AWS resources incur charges.
IaC checks and drift visibility
Deployment workflows include formatting, validation, and TFLint checks. tfsec and Checkov steps have been tested and are present as commented steps in the attached snapshot; enable them to run security checks in CI. For enforcement, retain each scanner's normal failure behavior. Where supported, optional soft-fail settings allow findings to be reported without blocking the workflow; the exact setting and effect depend on the tool or GitHub Action version. The regional Checkov example includes a commented soft_fail: true option, which should remain disabled when blocking findings is intended.

The drift workflows run Terraform plans and show their output directly in GitHub Actions. Their scheduled triggers are currently commented out to avoid unnecessary recurring runs in this demonstration. No separate alerting service is part of this project; GitHub's own workflow notifications depend on individual user settings.

Current drift-reporting detail: The workflow uses terraform plan -detailed-exitcode with continue-on-error: true, but later steps test steps.plan_drift.outputs.exitcode, which the plan step does not set. The reporting conditions therefore do not reliably distinguish exit codes 0, 1, and 2. Capture the exit code explicitly if separate drift detected, no change, and plan error messages are desired. The Terraform plan output remains available in the workflow log.
Implementation follow-ups
- Align the global plan artifact upload/download names (tfplan-global versus tfplan) so the saved plan can be applied.
- Capture and evaluate drift-check exit codes explicitly to make the existing GitHub Actions status messages accurate.
- Re-enable the tested tfsec and Checkov steps, keeping soft-fail behavior optional rather than the default enforcement mode.
Scope
This standalone repository demonstrates infrastructure provisioning and lifecycle automation across multiple AWS regions. Regional resource sets intentionally differ according to their configuration; matching compute deployments in every region are not a goal in themselves. It does not currently implement multi-region traffic routing, cross-region replication, disaster-recovery orchestration, or automatic failover.
Related architecture studies
Broader application, data, and resilience trade-offs are documented separately to keep this README focused on the Terraform implementation:
- Global Architecture Evolution
- Disaster Recovery Strategy
- Terraform project portfolio overview
These pages provide architectural context, not a claim that their proposed components are deployed by this repository.
