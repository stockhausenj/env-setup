# Claude CLI Ansible Role — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an Ansible role that installs Claude Code CLI on Windows (from WSL), configures plugins, deploys skills, with a bootstrap script for first-time setup.

**Architecture:** A standard Ansible role at `roles/claude/` with defaults, tasks, files, and templates. A PowerShell bootstrap script at the repo root handles WSL + Ansible prerequisites. All Windows commands in the role execute via `cmd.exe /c` from WSL.

**Tech Stack:** Ansible, PowerShell, Jinja2 templates, winget, npm

---

## File Map

| File | Responsibility |
|------|---------------|
| `roles/claude/defaults/main.yaml` | Default variables (plugins, skills, settings) |
| `roles/claude/tasks/main.yaml` | Install Node.js, Claude CLI, deploy config and skills |
| `roles/claude/templates/settings.json.j2` | Jinja2 template for Claude settings.json |
| `roles/claude/files/skills/hello-world/SKILL.md` | Bundled hello-world skill |
| `windows-claude.yml` | Playbook that includes the claude role |
| `windows-claude-setup.ps1` | Bootstrap script: WSL + Ansible + run playbook |

---

### Task 1: Role defaults and playbook

**Files:**
- Create: `roles/claude/defaults/main.yaml`
- Create: `windows-claude.yml`

- [ ] **Step 1: Create the defaults file**

```yaml
# roles/claude/defaults/main.yaml
---
# Windows user home (derived from WSL mount)
claude_windows_home: "/mnt/c/Users/{{ ansible_user_id }}"

# Claude config directory
claude_config_dir: "{{ claude_windows_home }}/.claude"

# Node.js major version for winget
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

- [ ] **Step 2: Create the playbook**

```yaml
# windows-claude.yml
# Run from WSL: ansible-playbook -i "localhost," -c local windows-claude.yml
---
- hosts: all
  tasks:
    - include_role:
        name: claude
```

- [ ] **Step 3: Commit**

```bash
git add roles/claude/defaults/main.yaml windows-claude.yml
git commit -m "feat(claude): add role defaults and playbook"
```

---

### Task 2: Settings template

**Files:**
- Create: `roles/claude/templates/settings.json.j2`

- [ ] **Step 1: Create the Jinja2 template**

```jinja2
{# roles/claude/templates/settings.json.j2 #}
{
  "model": "{{ claude_model }}",
  "enabledPlugins": {
{% for plugin in claude_plugins %}
    "{{ plugin }}": true{{ "," if not loop.last else "" }}
{% endfor %}
  },
  "alwaysThinkingEnabled": {{ claude_always_thinking | lower }}
}
```

This produces JSON like:

```json
{
  "model": "opus",
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "gopls-lsp@claude-plugins-official": true
  },
  "alwaysThinkingEnabled": true
}
```

- [ ] **Step 2: Commit**

```bash
git add roles/claude/templates/settings.json.j2
git commit -m "feat(claude): add settings.json jinja2 template"
```

---

### Task 3: Bundled hello-world skill

**Files:**
- Create: `roles/claude/files/skills/hello-world/SKILL.md`

- [ ] **Step 1: Create the skill file**

```markdown
---
name: hello-world
description: A simple greeting skill that responds with a friendly hello message
---

When the user asks for a hello or greeting, respond with a warm, friendly hello and offer to help them get started with Claude Code.
```

- [ ] **Step 2: Commit**

```bash
git add roles/claude/files/skills/hello-world/SKILL.md
git commit -m "feat(claude): add bundled hello-world skill"
```

---

### Task 4: Role tasks

**Files:**
- Create: `roles/claude/tasks/main.yaml`

- [ ] **Step 1: Create the tasks file**

```yaml
# roles/claude/tasks/main.yaml
---
# --- Node.js ---
- name: check if node is installed
  ansible.builtin.shell: cmd.exe /c "node --version"
  register: node_check
  changed_when: false
  failed_when: false

- name: install node.js via winget
  when: node_check.rc != 0
  ansible.builtin.shell: cmd.exe /c "winget install OpenJS.NodeJS.LTS --version {{ claude_node_version }}.* --accept-source-agreements --accept-package-agreements"
  register: node_install
  changed_when: "'Successfully installed' in node_install.stdout"

# --- Claude CLI ---
- name: check if claude is installed
  ansible.builtin.shell: cmd.exe /c "npx @anthropic-ai/claude-code --version"
  register: claude_check
  changed_when: false
  failed_when: false

- name: install claude cli
  when: claude_check.rc != 0
  ansible.builtin.shell: cmd.exe /c "npm install -g @anthropic-ai/claude-code"
  register: claude_install
  changed_when: "'added' in claude_install.stdout"

# --- Config directory ---
- name: create claude config directory
  ansible.builtin.file:
    path: "{{ claude_config_dir }}"
    state: directory
    mode: "0755"

# --- Settings ---
- name: deploy settings.json
  ansible.builtin.template:
    src: settings.json.j2
    dest: "{{ claude_config_dir }}/settings.json"
    mode: "0600"

# --- Skills directory ---
- name: create skills directory
  ansible.builtin.file:
    path: "{{ claude_config_dir }}/skills"
    state: directory
    mode: "0755"

# --- External skills (git clone) ---
- name: clone external skills
  ansible.builtin.git:
    repo: "{{ item.repo }}"
    dest: "{{ claude_config_dir }}/skills/{{ item.name }}"
    depth: 1
    update: true
  loop: "{{ claude_external_skills }}"

# --- Bundled skills (copy from role) ---
- name: deploy bundled skills
  ansible.builtin.copy:
    src: "skills/{{ item }}/"
    dest: "{{ claude_config_dir }}/skills/{{ item }}/"
    mode: "0644"
  loop: "{{ claude_bundled_skills }}"

# --- Post-install reminder ---
- name: remind user to login
  ansible.builtin.debug:
    msg: "Claude CLI installed. Run 'claude login' to authenticate."
```

- [ ] **Step 2: Verify role structure is complete**

Run: `find roles/claude -type f | sort`

Expected output:
```
roles/claude/defaults/main.yaml
roles/claude/files/skills/hello-world/SKILL.md
roles/claude/tasks/main.yaml
roles/claude/templates/settings.json.j2
```

- [ ] **Step 3: Commit**

```bash
git add roles/claude/tasks/main.yaml
git commit -m "feat(claude): add role tasks for node, cli, config, and skills"
```

---

### Task 5: Bootstrap PowerShell script

**Files:**
- Create: `windows-claude-setup.ps1`

- [ ] **Step 1: Create the bootstrap script**

```powershell
# windows-claude-setup.ps1
# Bootstrap script: installs WSL + Ansible, clones env-setup, runs the Claude playbook.
# Run from PowerShell as Administrator:
#   powershell -ExecutionPolicy Bypass -File windows-claude-setup.ps1

#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/stockhausenj/env-setup.git"
$WslRepoPath = "/home/$env:USERNAME/env-setup"

# --- WSL ---
Write-Host "Checking WSL..." -ForegroundColor Cyan
$wslCheck = wsl --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing WSL (this may require a reboot)..." -ForegroundColor Yellow
    wsl --install --no-launch
    if ($LASTEXITCODE -ne 0) {
        Write-Error "WSL install failed. If a reboot is needed, reboot and re-run this script."
        exit 1
    }
    Write-Host "WSL installed. If this is a first-time install, please reboot and re-run this script." -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}
Write-Host "WSL is available." -ForegroundColor Green

# --- Ensure Ubuntu is the default distro ---
Write-Host "Ensuring Ubuntu distro is set up..." -ForegroundColor Cyan
$distros = wsl --list --quiet 2>&1
if ($distros -notmatch "Ubuntu") {
    Write-Host "Installing Ubuntu distro..." -ForegroundColor Yellow
    wsl --install -d Ubuntu --no-launch
    Write-Host "Ubuntu installed. You may need to launch it once to set up your user, then re-run this script." -ForegroundColor Yellow
    wsl -d Ubuntu -- echo "Ubuntu ready"
}
Write-Host "Ubuntu distro available." -ForegroundColor Green

# --- Ansible ---
Write-Host "Installing Ansible in WSL..." -ForegroundColor Cyan
wsl -d Ubuntu -- bash -c "
    if command -v ansible-playbook &>/dev/null; then
        echo 'Ansible already installed.'
    else
        sudo apt-get update -qq
        sudo apt-get install -y -qq ansible git
        echo 'Ansible installed.'
    fi
"
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to install Ansible in WSL."; exit 1 }

# --- Clone repo ---
Write-Host "Cloning env-setup repo..." -ForegroundColor Cyan
wsl -d Ubuntu -- bash -c "
    if [ -d '$WslRepoPath' ]; then
        cd '$WslRepoPath' && git pull --ff-only
        echo 'Repo updated.'
    else
        git clone '$RepoUrl' '$WslRepoPath'
        echo 'Repo cloned.'
    fi
"
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to clone repo."; exit 1 }

# --- Run playbook ---
Write-Host "Running Claude playbook..." -ForegroundColor Cyan
wsl -d Ubuntu -- bash -c "
    cd '$WslRepoPath'
    ansible-playbook -i 'localhost,' -c local windows-claude.yml
"
if ($LASTEXITCODE -ne 0) { Write-Error "Playbook failed."; exit 1 }

Write-Host "" -ForegroundColor Green
Write-Host "Done! Claude CLI is installed." -ForegroundColor Green
Write-Host "Open a new terminal and run 'claude login' to authenticate." -ForegroundColor Yellow
```

- [ ] **Step 2: Commit**

```bash
git add windows-claude-setup.ps1
git commit -m "feat(claude): add bootstrap PowerShell script for WSL + Ansible setup"
```

---

### Task 6: Update spec with correct excalidraw URL

**Files:**
- Modify: `docs/superpowers/specs/2026-04-11-claude-ansible-role-design.md`

- [ ] **Step 1: Fix the excalidraw repo URL in the spec**

Change:
```
repo: "https://github.com/anthropics/claude-code-skills-excalidraw.git"  # verify exact URL at implementation time
```
To:
```
repo: "https://github.com/coleam00/excalidraw-diagram-skill.git"
```

- [ ] **Step 2: Commit**

```bash
git add docs/superpowers/specs/2026-04-11-claude-ansible-role-design.md
git commit -m "fix(claude): correct excalidraw skill repo URL in spec"
```

---

### Task 7: Final verification

- [ ] **Step 1: Verify complete role structure**

Run: `find roles/claude -type f | sort`

Expected:
```
roles/claude/defaults/main.yaml
roles/claude/files/skills/hello-world/SKILL.md
roles/claude/tasks/main.yaml
roles/claude/templates/settings.json.j2
```

- [ ] **Step 2: Verify playbook syntax**

Run from repo root:
```bash
ansible-playbook --syntax-check -i "localhost," -c local windows-claude.yml
```

Expected: `playbook: windows-claude.yml` (no errors)

- [ ] **Step 3: Verify template renders valid JSON**

Run:
```bash
ansible -i "localhost," -c local all -m template -a "src=roles/claude/templates/settings.json.j2 dest=/tmp/claude-settings-test.json" && python3 -m json.tool /tmp/claude-settings-test.json
```

Expected: valid JSON output matching the expected structure.

- [ ] **Step 4: Verify the PowerShell script has no syntax errors**

Run:
```bash
pwsh -NoExecute -File windows-claude-setup.ps1 2>&1 || echo "pwsh not available, skip"
```

If `pwsh` is not installed locally, this is optional — the script will be tested on the Windows target.

- [ ] **Step 5: Final commit if any fixes were needed**

Only if previous steps revealed issues that required changes.
