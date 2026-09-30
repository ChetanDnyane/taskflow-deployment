# TaskFlow Terraform

This folder is a clean Terraform definition for the AWS infrastructure used by TaskFlow.

## What it creates

- VPC
- 3 public subnets for EKS worker nodes / public Kubernetes load balancers
- 3 isolated private subnets for RDS
- Internet Gateway and public routing
- EKS cluster
- One managed EKS node group
- RDS PostgreSQL
- EKS/RDS security groups
- Three ECR repositories

It intentionally does **not** create a NAT Gateway, to avoid NAT Gateway hourly/data-processing cost in this learning environment.

It also intentionally keeps **Helm separate from Terraform**. Terraform creates AWS infrastructure; Helm deploys TaskFlow into Kubernetes.

## Important: current manually-created infrastructure

Do NOT run `terraform apply` against the currently running manually-created TaskFlow AWS environment without reviewing the plan.

If the three ECR repositories already exist and you want this Terraform state to manage them, import them before applying:

```powershell
terraform import aws_ecr_repository.auth taskflow-auth-service
terraform import aws_ecr_repository.task taskflow-task-service
terraform import aws_ecr_repository.ui taskflow-ui
```

The current manually-created EKS/RDS/VPC resources are not automatically adopted by this configuration. A clean learning path is:

1. Study and validate this configuration.
2. Finish with the current manual environment.
3. Clean up the manual EKS/RDS/load-balancer infrastructure.
4. Use this Terraform configuration to create the next environment from scratch.

## First commands

```powershell
terraform init
terraform fmt
terraform validate
terraform plan
```

Review the plan carefully before:

```powershell
terraform apply
```

## After EKS creation

Configure kubectl:

```powershell
terraform output -raw eks_update_kubeconfig_command
```

Run the printed command.

## RDS password

RDS uses:

```hcl
manage_master_user_password = true
```

AWS stores the master credentials in AWS Secrets Manager instead of putting the password in Terraform variables.

Get the secret ARN:

```powershell
terraform output -raw rds_master_secret_arn
```

You can then retrieve the secret through AWS CLI if your organization's IAM/SCP permissions allow `secretsmanager:GetSecretValue`.

## Second TaskFlow database

Terraform creates the initial `taskflow` database. PostgreSQL does not provide a simple RDS API option to create the second `taskflow_tasks` database.

After RDS is available, connect from EKS with a temporary PostgreSQL client pod and run:

```sql
CREATE DATABASE taskflow_tasks;
```

This matches the manual setup you already tested.

## Helm

After infrastructure is ready, use the existing TaskFlow Helm chart with `values-aws.yaml`.

Update its RDS endpoint and ECR repository URLs from Terraform outputs if they differ from the old manually-created environment.

## Organization SCP caveat

Your current AWS organization has an SCP that explicitly denied `iam:GetOpenIDConnectProvider`. Because of that restriction, this package does not attempt to install the AWS Load Balancer Controller or create an IRSA/OIDC setup.

Your current Kubernetes `Service` of type `LoadBalancer` worked without that controller in the manually-created environment. Re-test that behavior after recreating the cluster.

## Cost warning

EKS, EC2 worker nodes, RDS, public load balancers, ECR storage, Secrets Manager, and other AWS services can incur charges. Always review the AWS pricing/free-plan rules applicable to your account and clean up resources when you are finished.

Do not run `terraform destroy` casually: it deletes resources tracked in the active Terraform state, including imported ECR repositories.
