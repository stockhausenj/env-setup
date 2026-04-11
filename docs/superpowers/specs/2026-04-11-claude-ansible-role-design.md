# Claude CLI Ansible Role — Design Spec

## Overview

An Ansible role that installs and configures Claude Code CLI on a Windows machine, run from WSL. Includes a bootstrap script that sets up WSL + Ansible as prerequisites, then executes the playbook.

## Goals

- Install Node.js and Claude CLI on Windows via winget/npm
- Deploy Claude settings.json with plugins configured
- Deploy skills: external (git-cloned) and bundled (shipped in the role)
- Provide a single bootstrap script so the user just runs one command

## File Structure

```
roles/claude/
├── defaults/
│   └── main.yaml              # Default variables
├── tasks/
│   └── main.yaml              # Main task file
├── files/
│   └── skills/
│       └── hello-world/
│           └── SKILL.md       # Bundled hello-world skill
├── templates/
│   └── settings.json.j2       # Claude settings.json
windows-claude-setup.ps1       # Bootstrap PowerShell script (repo root)
windows-claude.yml             # Playbook (repo root)
```

## Bootstrap Script (`windows-claude-setup.ps1`)

A PowerShell script the user runs from a regular PowerShell prompt. Steps:

1. **Enable WSL** — `wsl --install` if not already present. Handles reboot requirement.
2. **Install Ansible in WSL** — `apt-get install ansible` inside WSL.
3. **Clone this repo** — Clones env-setup into WSL filesystem.
4. **Run the playbook** — `ansible-playbook -i "localhost," -c local windows-claude.yml`.

Properties:
- Idempotent (safe to re-run)
- Named `.ps1` for native Windows execution
- Requires admin privileges (for WSL install)

## Variables (`defaults/main.yaml`)

```yaml
# Windows user home (derived from WSL mount)
claude_windows_home: "/mnt/c/Users/{{ ansible_user_id }}"

# Claude config directory
claude_config_dir: "{{ claude_windows_home }}/.claude"

# Node.js
claude_node_version: "22"

# Plugins to enable in settings.json
claude_plugins:
  - "superpowers@claude-plugins-official"
  - "frontend-design@claude-plugins-official"
  - "code-review@claude-plugins-official"
  - "gopls-lsp@claude-plugins-official"

# Claude settings
claude_model: "opus"
claude_always_thinking: true

# External skills (cloned from git)
claude_external_skills:
  - name: "excalidraw-diagram-skill"
    repo: "https://github.com/coleam00/excalidraw-diagram-skill.git"

# Bundled skills (deployed from role's files/skills/)
claude_bundled_skills:
  - "hello-world"
```

## Task Flow (`tasks/main.yaml`)

1. **Install Node.js** — `cmd.exe /c winget install OpenJS.NodeJS.LTS`. Check if installed first for idempotency.
2. **Install Claude CLI** — `cmd.exe /c npm install -g @anthropic-ai/claude-code`. Check version for changed state.
3. **Create Claude config directory** — Ensure `{{ claude_config_dir }}` exists.
4. **Deploy settings.json** — Template `settings.json.j2` to `{{ claude_config_dir }}/settings.json`.
5. **Create skills directory** — Ensure `{{ claude_config_dir }}/skills/` exists.
6. **Clone external skills** — Loop `claude_external_skills`, git clone each to `{{ claude_config_dir }}/skills/{{ item.name }}`. Uses `creates:` for idempotency.
7. **Deploy bundled skills** — Loop `claude_bundled_skills`, copy each from `files/skills/` to `{{ claude_config_dir }}/skills/`.

All Windows-side commands execute through `cmd.exe` since Ansible runs in WSL.

## Templates

### `settings.json.j2`

Generates Claude's `~/.claude/settings.json` with:
- `model` from `claude_model`
- `enabledPlugins` built from `claude_plugins` list (each set to `true`)
- `alwaysThinkingEnabled` from `claude_always_thinking`

## Bundled Skills

### hello-world (`files/skills/hello-world/SKILL.md`)

A minimal skill that responds to greetings. Serves as both a functional skill and a template for creating new bundled skills.

Adding a new bundled skill:
1. Create `files/skills/<skill-name>/SKILL.md`
2. Append skill name to `claude_bundled_skills` variable

## Playbook (`windows-claude.yml`)

```yaml
# Run from WSL: ansible-playbook -i "localhost," -c local windows-claude.yml
---
- hosts: all
  tasks:
    - include_role:
        name: claude
```

## Post-Install

After the role completes, the user must manually run `claude login` to authenticate.
