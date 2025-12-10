# Technology Stack

## Core Technologies

- **Terraform**: Infrastructure provisioning and management
- **Terragrunt**: DRY Terraform configurations and remote state management
- **AWS**: Primary cloud provider
- **Thoth**: Project scaffolding and templating tool

## Build System & Tools

- **Terragrunt**: Primary orchestration tool for Terraform
- **TFLint**: Terraform linting and validation
- **Pre-commit**: Git hooks for code quality
- **MkDocs**: Documentation generation

## Common Commands


## Common Commands

### Environment Setup
```bash
# Set environment variable (required)
export TF_VAR_ENVIRONMENT=dev  # or qa, stg, prod

# Initialize a stack
terragrunt init

# Plan changes
terragrunt plan

# Apply changes
terragrunt apply

# Destroy resources
terragrunt destroy
```

### Multi-stack Operations
```bash
# Run command across all stacks
terragrunt run --all plan
terragrunt run --all apply
terragrunt run --all destroy


# Run command for specific layer
terragrunt run --all --working-dir stacks/foundation -- plan
```


### Validation & Linting
```bash
# Run TFLint
tflint --recursive

# Run pre-commit hooks
pre-commit run --all-files

# Validate Terraform syntax
terragrunt validate
```

## Configuration Management

- **Remote State**: S3 backend with DynamoDB locking
- **Variable Files**: Hierarchical variable precedence
- **Workspaces**: Environment separation using Terraform workspaces
- **Templates**: Thoth templating for project scaffolding

## Key Configuration Files

- `root.hcl`: Root Terragrunt configuration
- `common/common.hcl`: Shared variables and provider configuration
- `common/common.tfvars`: Common variable values
- `.thothcf.toml`: Project templating configuration
- `.tflint.hcl`: Linting rules and configuration