# Azure DevOps Skill & CLI — Design Spec

## Overview

Add a bundled Azure DevOps skill to the claude Ansible role that teaches Claude how to interact with ADO using the `az devops` CLI. Also add Azure CLI + devops extension installation to the role tasks. Primary focus on work items and boards (engineering manager workflow), with lighter coverage of pipelines and repos/PRs.

## Goals

- Install Azure CLI and devops extension on macOS and Ubuntu
- Configure ADO org/project defaults when provided
- Create a comprehensive bundled skill for ADO interaction via `az devops` CLI
- Deep coverage: work items, boards/sprints
- Light coverage: pipelines, repos/PRs

## Changes

### defaults/main.yaml

Add ADO configuration variables:

```yaml
# Azure DevOps defaults (set to configure az devops CLI defaults)
claude_ado_organization: ""
claude_ado_project: ""
```

Add `azure-devops` to bundled skills list:

```yaml
claude_bundled_skills:
  - "hello-world"
  - "azure-devops"
```

### tasks/main.yaml

Add between the GitHub CLI section and the Claude CLI section:

**Azure CLI install (platform-specific):**
- macOS: `community.general.homebrew: name=azure-cli`
- Ubuntu: `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash` with `creates: /usr/bin/az`

**Azure DevOps extension (shared):**
- `az extension add --name azure-devops --yes`

**ADO defaults (conditional):**
- When `claude_ado_organization` is not empty, run `az devops configure --defaults organization=... project=...`

**Update post-install reminder:**
- Add `az login` and `az devops configure` to the reminder message

### files/skills/azure-devops/SKILL.md

A comprehensive skill file with the following sections:

**Frontmatter:**
- name: azure-devops
- description: Interact with Azure DevOps work items, boards, and pipelines using the az devops CLI

**Prerequisites:**
- Check `az devops configure --list` for org/project defaults
- If not configured, ask the user

**Work Items (deep coverage):**
- Query with WIQL (`az boards query --wiql`)
- Common WIQL patterns: my items, sprint items, bugs by state, unassigned
- Create (`az boards work-item create`)
- Update (`az boards work-item update`) — state, assignment, comments
- Show details (`az boards work-item show`)
- Link work items (parent/child, related)

**Boards (deep coverage):**
- List iterations/sprints (`az boards iteration`)
- Sprint capacity and team settings
- Backlog queries via WIQL filtered by iteration path

**Pipelines (light coverage):**
- List pipelines (`az pipelines list`)
- Show runs (`az pipelines runs list`)
- Trigger a run (`az pipelines run`)
- Check run status

**Repos/PRs (light coverage):**
- List PRs (`az repos pr list`)
- Create PR (`az repos pr create`)
- Show PR details and reviewers
