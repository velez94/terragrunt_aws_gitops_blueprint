# Project Structure

## Directory Organization

The project follows a layered architecture with clear separation of concerns:

```
├── stacks/                    # Infrastructure stacks organized by layers
│   ├── foundation/           # Base infrastructure (VPC, IAM, Security)
│   │   ├── network/         # Networking components
│   │   └── iam/             # Identity and access management
│   ├── platform/            # Shared services (EKS, RDS, ElastiCache)
│   │   ├── containers/      # Container orchestration
│   │   └── data/            # Data services
│   ├── application/         # Application-specific infrastructure
│   │   ├── compute/         # Load balancers, auto scaling
│   │   └── storage/         # S3, EFS storage
│   └── observability/       # Monitoring and logging
│       └── monitoring/      # CloudWatch, Prometheus
├── common/                  # Shared configuration and variables
├── environments/            # Environment-specific configurations
├── docs/                    # Project documentation
└── .kiro/                   # Kiro-specific configurations
```

## Stack Structure Convention

Each stack follows a standardized structure:

```
stack-name/
├── terragrunt.hcl          # Terragrunt configuration and dependencies
├── main.tf                 # Main Terraform resources
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
└── versions.tf             # Provider version constraints (optional)
```

## Naming Conventions

### Stack Paths
```
stacks/{layer}/{domain}/{service}/
```

**Examples:**
- `stacks/foundation/network/vpc/`
- `stacks/platform/containers/eks/`
- `stacks/application/compute/alb/`
- `stacks/observability/monitoring/cloudwatch/`

### Layers (in dependency order)
1. **foundation**: Core infrastructure (VPC, IAM, Security Groups)
2. **platform**: Shared services (EKS, RDS, ElastiCache, ECR)
3. **application**: Application-specific resources (ALB, ASG, S3, EFS)
4. **observability**: Monitoring and logging (CloudWatch, Prometheus)

## Dependency Rules

- **Foundation** → Platform → Application → Observability
- Stacks can depend on other stacks in the same layer
- Never depend on higher layers
- Dependencies must be explicitly declared in `terragrunt.hcl`

## Configuration Hierarchy

### Variable Precedence (highest to lowest)
1. Environment-specific files (`environments/{env}/*.tfvars`)
2. Common variables (`common/common.tfvars`)
3. Stack-specific variables
4. Default values in `variables.tf`

### Key Files
- `root.hcl`: Root Terragrunt configuration with remote state
- `common/common.hcl`: Shared locals and provider generation
- `common/common.tfvars`: Common variable values
- `environments/{env}/*.tfvars`: Environment-specific overrides

## Required Tags

All resources must include these tags:
```hcl
tags = {
  ProjectCode = var.project_name
  Framework   = "DevSecOps-IaC"
  Environment = var.environment
  ManagedBy   = "terragrunt"
}
```

## File Naming Standards

- Use lowercase with hyphens for directories
- Use snake_case for Terraform files
- Use descriptive names that indicate purpose
- Keep stack names concise but clear