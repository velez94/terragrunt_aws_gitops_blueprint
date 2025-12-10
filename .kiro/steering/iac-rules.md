# Infrastructure as Code Composition Rules

## Rule Enforcement
These are mandatory rules enforced by Amazon Q for all Terragrunt/Terraform operations in this project.

## R001: Module Source Restrictions
**RULE**: Only use approved module sources
**ENFORCEMENT**: Block any module not from approved sources

### Approved Sources (in priority order):
1. `terraform-aws-modules/*` - Official AWS modules (REQUIRED)
2. `hashicorp/aws` provider resources (ALLOWED)
3. HashiCorp Verified modules (REQUIRES_APPROVAL)

### Required Format:
```hcl
terraform {
  source = "tfr:///terraform-aws-modules/{module-name}/aws?version={version}"
}
```

**VIOLATION**: Using community or unverified modules
**ACTION**: Reject and suggest approved alternative

## R002: Version Pinning
**RULE**: All modules must specify exact versions
**ENFORCEMENT**: Block any module without version constraint

### Required Pattern:
```hcl
source = "tfr:///terraform-aws-modules/vpc/aws?version=5.0.0"
```

**VIOLATION**: Missing or loose version constraints (`>=`, `~>`)
**ACTION**: Require exact version specification

## R003: Naming Convention
**RULE**: All resources must follow naming pattern
**ENFORCEMENT**: Validate naming against pattern

### Required Format:
```
{project}-{environment}-{resource-type}
```

### Implementation:
```hcl
name = "${local.common_vars.locals.project}-${local.environment}-{resource-type}"
```

**VIOLATION**: Names not following pattern
**ACTION**: Reject and provide correct format

## R004: Mandatory Tagging
**RULE**: All resources must include required tags
**ENFORCEMENT**: Block resources missing mandatory tags

### Required Tags:
```hcl
tags = merge(local.common_vars.locals.tags, {
  Name        = "${local.common_vars.locals.project}-${local.environment}-{resource}"
  Layer       = "{foundation|platform|application|observability}"
  Domain      = "{network|compute|storage|security|data}"
  Component   = "{specific-component}"
  Environment = local.environment
})
```

**VIOLATION**: Missing any required tag
**ACTION**: Reject and specify missing tags

## R005: Dependency Declaration
**RULE**: Use `dependency` blocks, never `dependencies`
**ENFORCEMENT**: Block usage of deprecated `dependencies`

### Required Pattern:
```hcl
dependency "vpc" {
  config_path = "../../../foundation/network/vpc"
  mock_outputs = {
    vpc_id = "vpc-mock"
    private_subnets = ["subnet-mock1", "subnet-mock2"]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}
```

**VIOLATION**: Using `dependencies` block
**ACTION**: Convert to `dependency` blocks with mock outputs

## R006: Security Requirements
**RULE**: Enforce security best practices
**ENFORCEMENT**: Block insecure configurations

### Mandatory Security Settings:
- Encryption at rest: `encrypted = true`
- Private subnets for workloads
- No hardcoded secrets
- IAM least privilege

**VIOLATION**: Insecure configurations
**ACTION**: Reject and require security compliance

## R007: Environment Configuration
**RULE**: Use locals pattern for environment-specific config
**ENFORCEMENT**: Validate environment configuration structure

### Required Pattern:
```hcl
locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common/common.hcl"))
  environment = get_env("TF_WORKSPACE", "dev")
  
  env_config = {
    dev  = { /* dev config */ }
    prod = { /* prod config */ }
  }
  
  workspace_config = lookup(local.env_config, local.environment, local.env_config.dev)
}
```

**VIOLATION**: Hardcoded environment values
**ACTION**: Require locals-based configuration

## R008: Mock Outputs Requirement
**RULE**: All dependencies must include mock outputs
**ENFORCEMENT**: Block dependencies without mocks

### Required Elements:
- `mock_outputs` block with realistic values
- `mock_outputs_merge_strategy_with_state = "shallow"`

**VIOLATION**: Missing mock outputs
**ACTION**: Require mock outputs for safe planning

## R009: Documentation Requirement
**RULE**: All stacks must include README.md
**ENFORCEMENT**: Validate documentation exists

### Required Content:
- Purpose and description
- Input variables
- Output values
- Dependencies
- Usage examples

**VIOLATION**: Missing or incomplete documentation
**ACTION**: Require complete documentation

## R010: Layer Architecture
**RULE**: Respect architectural layers
**ENFORCEMENT**: Validate stack placement and dependencies

### Layer Hierarchy:
1. **Foundation**: VPC, IAM, core services
2. **Platform**: EKS, shared services
3. **Application**: App-specific resources
4. **Observability**: Monitoring, logging

### Dependency Rules:
- Higher layers can depend on lower layers
- Same layer dependencies allowed
- Lower layers cannot depend on higher layers

**VIOLATION**: Invalid layer dependencies
**ACTION**: Reject and suggest correct architecture

## Enforcement Actions

### BLOCK: Immediate rejection
- R001: Unapproved module sources
- R002: Missing version constraints
- R005: Using `dependencies` instead of `dependency`
- R006: Security violations

### WARN: Require confirmation
- R003: Naming convention violations
- R004: Missing tags
- R007: Environment configuration issues

### REQUIRE: Must fix before proceeding
- R008: Missing mock outputs
- R009: Missing documentation
- R010: Architecture violations

## Agent Behavior Rules

### When Creating New Stacks:
1. Always use latest stable version from `terraform-aws-modules`
2. Generate complete terragrunt.hcl with all required elements
3. Create README.md with full documentation
4. Validate against all rules before suggesting

### When Modifying Existing Stacks:
1. Preserve existing patterns unless upgrading
2. Validate all changes against rules
3. Update documentation if inputs/outputs change
4. Maintain backward compatibility

### When Researching Modules:
1. Search `terraform-aws-modules` first
2. Use submodules when available
3. Check compatibility with project Terraform version
4. Suggest latest stable version

## Exceptions Process

### Emergency Override:
- Document reason in commit message
- Create issue for rule compliance
- Fix within 48 hours

### Permanent Exception:
- Requires architecture team approval
- Document in stack README
- Update rules if pattern becomes standard

## Rule Updates

### Version Control:
- All rule changes require PR review
- Breaking changes need migration guide
- Backward compatibility for 2 versions

### Communication:
- Announce rule changes in team channels
- Update agent training data
- Provide migration examples

These rules ensure consistent, secure, and maintainable infrastructure code while enabling Amazon Q to provide automated enforcement and guidance.