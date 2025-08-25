# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Repository Overview

This repository contains a collection of Nix flake-based development
environments for different use cases. Each subdirectory represents a
specialized development environment with its own `flake.nix` configuration
file.

## Key Commands

### Environment Management
- `just create_reg` - Generate registry.json with all flake environments
- `just install [path]` - Install registry to ~/.config/nix/ (default) or
  specified path
- `just clean` - Remove generated registry.json file
- `just update_nixlock <input>` - Update flake locks for environments
  depending on specified input

### Entering Environments
- `nix develop .#<environment>` - Enter specific environment shell
- `nix develop github:Joelgranados/nenvs?dir=<environment>` - Enter
  environment from GitHub

### Remote Execution (krc tool)
- `./krc/krc <host> -- <command>` - Execute commands on remote hosts with
  mutagen sync
- `./krc/krc -x <arch> <host> -- <command>` - Cross-compile for specified
  architecture
- `./krc/krc -e <env> <host> -- <command>` - Use specific environment
  (kernel_base, qemu_base)

### VDI Management
- `./vdi/vdictrl.sh -n <vm_name> -a start` - Start VDI virtual machine
- `./vdi/vdictrl.sh -n <vm_name> -a stop` - Stop VDI virtual machine

## Architecture

### Environment Structure
Each environment directory contains:
- `flake.nix` - Nix flake configuration defining packages and shell hooks
- `flake.lock` - Locked dependency versions

### Core Environments
- `env_shell/` - Base shell environment with zsh configuration and prompt
  customization
- `kernel/` - Kernel development environment with compilation tools
- `kernel_base/` - Base kernel environment for other kernel-related
  environments
- `qemu/` and `qemu_base/` - QEMU virtualization environments
- `test/` - Testing environment
- `vdi/` - Virtual desktop infrastructure with virt-manager and libvirt
- `nenvs/` - Meta-environment with just and claude-code tools

### Environment Inheritance
Environments use a hierarchical structure where specialized environments
inherit from base environments:
- Most environments inherit shell hooks from `env_shell`
- Kernel-related environments inherit from `kernel_base`
- QEMU environments inherit from `qemu_base`

### Registry System
The `justfile` and `registry.tmpl` work together to generate a Nix registry
mapping environment names to their GitHub locations, enabling shorthand
references like `nix develop kernel` instead of full GitHub URLs.

### Cross-compilation Support
The `krc` tool integrates with an external toolchain_ctl system to provide
cross-compilation capabilities for kernel development across different
architectures.

## Environment Variables

Key environment variables used across environments:
- `NIX_ENV_SHELL_PROMPT_PREFIX` - Custom prompt prefix for environment
  identification
- `NIX_ENV_SHELL_ZSHRC_PREFIX` - Additional zsh configuration per environment
- `KBUILD_*` variables - Kernel build reproducibility settings in krc tool

## Development Workflow

1. Use `just create_reg && just install` to set up the registry
2. Enter desired environment with `nix develop <env_name>`
3. For kernel development, use `krc` for remote compilation and testing
4. Use VDI environments for graphical virtual machine management
5. Each environment automatically configures its shell with appropriate tools
   and settings

## Code Style Guidelines

- Wrap lines that exceed 90 characters for better readability

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only
create documentation files if explicitly requested by the User.
