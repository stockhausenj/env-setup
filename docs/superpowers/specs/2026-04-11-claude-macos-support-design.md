# Claude Ansible Role — macOS Support Design Spec

## Overview

Update the existing `roles/claude` Ansible role to support macOS in addition to Ubuntu/WSL. Both platforms run Claude CLI natively (not via Windows cmd.exe), so they share the same config directory and CLI install path. Only the Node.js package install differs by platform.

## Goals

- Add macOS support to the existing claude role using platform conditionals
- Simplify the Windows/WSL tasks to also install natively (not via cmd.exe)
- Add the claude role to the `macos-min.yml` playbook

## Changes

### defaults/main.yaml

- Remove `claude_windows_home` variable
- Change `claude_config_dir` to `{{ ansible_facts['env']['HOME'] }}/.claude` (works on both macOS and Ubuntu/WSL)
- All other variables (plugins, skills, model, thinking) remain unchanged

### tasks/main.yaml

**Platform-specific tasks (conditionals):**

- **macOS (Darwin):** Install Node.js via `brew install node`
- **Ubuntu/WSL:** Install Node.js and npm via `apt-get install nodejs npm` with `become: true`

**Shared tasks (no conditionals):**

- Check if Claude CLI is installed via `claude --version`
- Install Claude CLI via `npm install -g @anthropic-ai/claude-code` (if not present)
- Create Claude config directory
- Deploy settings.json from template
- Create skills directory
- Clone external skills (git)
- Deploy bundled skills (copy)
- Post-install reminder

### windows-claude.yml

Simplify — remove the vars override for `claude_config_dir` since the default now works for WSL:

```yaml
- hosts: all
  tasks:
    - include_role:
        name: claude
```

### macos-min.yml

Add the claude role at the end of the existing task list:

```yaml
    - include_role:
        name: claude
```

### windows-claude-setup.ps1

No changes needed. It already bootstraps WSL + Ansible and runs the playbook.

### templates/settings.json.j2

No changes needed. Works for both platforms.

### files/skills/

No changes needed. Bundled skills are platform-independent.
