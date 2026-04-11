# Claude Role macOS Support — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the claude Ansible role to support both macOS and Ubuntu/WSL using platform conditionals, and add it to the macos-min.yml playbook.

**Architecture:** Replace Windows-specific cmd.exe tasks with platform-conditional native installs (brew on macOS, apt on Ubuntu). Shared tasks (CLI install, config, skills) remain unconditional. Defaults become platform-agnostic.

**Tech Stack:** Ansible, Homebrew, apt, npm

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `roles/claude/defaults/main.yaml` | Modify | Remove `claude_windows_home`, make `claude_config_dir` platform-agnostic |
| `roles/claude/tasks/main.yaml` | Modify | Replace cmd.exe tasks with platform conditionals + shared tasks |
| `macos-min.yml` | Modify | Add `include_role: name=claude` at end |

---

### Task 1: Update defaults to be platform-agnostic

**Files:**
- Modify: `roles/claude/defaults/main.yaml`

- [ ] **Step 1: Replace the defaults file contents**

Replace the entire file with:

```yaml
---
# Claude config directory (works on both macOS and Ubuntu/WSL)
claude_config_dir: "{{ ansible_facts['env']['HOME'] }}/.claude"

# Node.js major version
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

Changes from previous version:
- Removed `claude_windows_home` variable
- Changed `claude_config_dir` from `{{ claude_windows_home }}/.claude` to `{{ ansible_facts['env']['HOME'] }}/.claude`

- [ ] **Step 2: Commit**

```bash
git add roles/claude/defaults/main.yaml
git commit -m "feat(claude): make defaults platform-agnostic for macOS + Ubuntu support"
```

---

### Task 2: Update tasks with platform conditionals

**Files:**
- Modify: `roles/claude/tasks/main.yaml`

- [ ] **Step 1: Replace the entire tasks file**

Replace the entire file with:

```yaml
---
# --- Node.js (platform-specific) ---
- name: install node.js on macOS
  when: ansible_facts['os_family'] == 'Darwin'
  community.general.homebrew:
    name: node
    state: present

- name: install node.js on Ubuntu
  when: ansible_facts['distribution'] == 'Ubuntu'
  ansible.builtin.apt:
    name:
      - nodejs
      - npm
    state: present
  become: true

# --- Claude CLI (shared) ---
- name: check if claude is installed
  ansible.builtin.shell: claude --version
  register: claude_check
  changed_when: false
  failed_when: false

- name: install claude cli
  when: claude_check.rc != 0
  ansible.builtin.shell: npm install -g @anthropic-ai/claude-code
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

Changes from previous version:
- Replaced `cmd.exe /c "node --version"` check + `cmd.exe /c winget install` with `community.general.homebrew` (macOS) and `ansible.builtin.apt` (Ubuntu)
- Replaced `cmd.exe /c "npx @anthropic-ai/claude-code --version"` with `claude --version`
- Replaced `cmd.exe /c "npm install -g @anthropic-ai/claude-code"` with native `npm install -g`
- All shared tasks (config, settings, skills) are unchanged

- [ ] **Step 2: Commit**

```bash
git add roles/claude/tasks/main.yaml
git commit -m "feat(claude): add macOS support with platform conditionals, simplify WSL tasks"
```

---

### Task 3: Add claude role to macos-min.yml

**Files:**
- Modify: `macos-min.yml`

- [ ] **Step 1: Add the claude role at the end of macos-min.yml**

Add these two lines at the end of the file (after the `tmux` role include):

```yaml
    - include_role:
        name: claude
```

The full file should end with:

```yaml
    - include_role:
        name: tmux
    - include_role:
        name: claude
```

- [ ] **Step 2: Verify playbook syntax**

Run:
```bash
ansible-playbook --syntax-check -i "localhost," -c local macos-min.yml
```

Expected: `playbook: macos-min.yml` (no errors)

- [ ] **Step 3: Commit**

```bash
git add macos-min.yml
git commit -m "feat(claude): add claude role to macos-min playbook"
```

---

### Task 4: Verify everything works together

- [ ] **Step 1: Verify role file structure is unchanged**

Run: `find roles/claude -type f | sort`

Expected:
```
roles/claude/defaults/main.yaml
roles/claude/files/skills/hello-world/SKILL.md
roles/claude/tasks/main.yaml
roles/claude/templates/settings.json.j2
```

- [ ] **Step 2: Syntax check both playbooks**

Run:
```bash
ansible-playbook --syntax-check -i "localhost," -c local macos-min.yml
ansible-playbook --syntax-check -i "localhost," -c local windows-claude.yml
```

Expected: Both pass with no errors.

- [ ] **Step 3: Verify template still renders valid JSON**

Run:
```bash
ansible -i "localhost," -c local all -m template -a "src=roles/claude/templates/settings.json.j2 dest=/tmp/claude-settings-test.json" -e '{"claude_model":"opus","claude_plugins":["superpowers@claude-plugins-official","frontend-design@claude-plugins-official","code-review@claude-plugins-official","gopls-lsp@claude-plugins-official"],"claude_always_thinking":true}' && python3 -m json.tool /tmp/claude-settings-test.json
```

Expected: Valid JSON output.

- [ ] **Step 4: Final commit if any fixes were needed**

Only if previous steps revealed issues.
