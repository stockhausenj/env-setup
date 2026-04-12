---
name: azure-devops
description: Interact with Azure DevOps work items, boards, and pipelines using the az devops CLI
---

# Azure DevOps Skill

Use the `az devops` CLI to interact with Azure DevOps. This skill covers work items, boards, pipelines, and repos.

## Prerequisites

Before running any ADO commands, check if defaults are configured:

```bash
az devops configure --list
```

If organization or project are not set, ask the user for their values and run:

```bash
az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>
```

If `az` is not authenticated, ask the user to run `az login`.

## Work Items

### Query work items with WIQL

Use `az boards query` with WIQL (Work Item Query Language) to search for work items.

**My assigned items:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo] FROM workitems WHERE [System.AssignedTo] = @Me AND [System.State] <> 'Closed' ORDER BY [System.ChangedDate] DESC" --output table
```

**All active bugs:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo], [Microsoft.VSTS.Common.Priority] FROM workitems WHERE [System.WorkItemType] = 'Bug' AND [System.State] = 'Active' ORDER BY [Microsoft.VSTS.Common.Priority] ASC" --output table
```

**Items in current sprint:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo], [System.WorkItemType] FROM workitems WHERE [System.IterationPath] = @CurrentIteration AND [System.State] <> 'Closed' ORDER BY [System.WorkItemType] ASC" --output table
```

**Unassigned items in a sprint:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType] FROM workitems WHERE [System.IterationPath] = @CurrentIteration AND [System.AssignedTo] = '' ORDER BY [System.WorkItemType] ASC" --output table
```

**Items by state:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.AssignedTo] FROM workitems WHERE [System.State] = 'New' AND [System.WorkItemType] = 'User Story' ORDER BY [System.CreatedDate] DESC" --output table
```

### Show work item details

```bash
az boards work-item show --id <ID> --output table
```

For full JSON details (useful for reading all fields):
```bash
az boards work-item show --id <ID> --output json
```

### Create work items

**Create a user story:**
```bash
az boards work-item create --type "User Story" --title "As a user, I want to..." --assigned-to "user@example.com" --iteration "Project\Sprint 1" --output table
```

**Create a bug:**
```bash
az boards work-item create --type "Bug" --title "Bug title" --assigned-to "user@example.com" --priority 2 --output table
```

**Create a task:**
```bash
az boards work-item create --type "Task" --title "Task title" --assigned-to "user@example.com" --output table
```

### Update work items

**Change state:**
```bash
az boards work-item update --id <ID> --state "Active" --output table
```

**Reassign:**
```bash
az boards work-item update --id <ID> --assigned-to "user@example.com" --output table
```

**Add a comment:**
```bash
az boards work-item update --id <ID> --discussion "Comment text here" --output table
```

**Update multiple fields:**
```bash
az boards work-item update --id <ID> --state "Resolved" --assigned-to "user@example.com" --discussion "Fixed in PR #123" --output table
```

### Link work items

**Add a parent link:**
```bash
az boards work-item relation add --id <CHILD_ID> --relation-type "System.LinkTypes.Hierarchy-Reverse" --target-id <PARENT_ID>
```

**Add a child link:**
```bash
az boards work-item relation add --id <PARENT_ID> --relation-type "System.LinkTypes.Hierarchy-Forward" --target-id <CHILD_ID>
```

**Add a related link:**
```bash
az boards work-item relation add --id <ID> --relation-type "System.LinkTypes.Related" --target-id <OTHER_ID>
```

## Boards and Sprints

### List iterations (sprints)

**All iterations for the project:**
```bash
az boards iteration project list --output table
```

**Team iterations (sprints the team is subscribed to):**
```bash
az boards iteration team list --team "<Team Name>" --output table
```

### Current sprint work

Combine WIQL with iteration path to get sprint-specific views:

**Sprint burndown — items by state:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType], [System.AssignedTo] FROM workitems WHERE [System.IterationPath] = @CurrentIteration ORDER BY [System.State] ASC" --output table
```

**Sprint items grouped by assignee:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType], [System.AssignedTo] FROM workitems WHERE [System.IterationPath] = @CurrentIteration AND [System.State] <> 'Closed' ORDER BY [System.AssignedTo] ASC" --output table
```

### Backlog queries

**Product backlog (not in any sprint):**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [Microsoft.VSTS.Common.Priority] FROM workitems WHERE [System.WorkItemType] = 'User Story' AND [System.State] = 'New' AND [System.IterationPath] = '<Project>\Backlog' ORDER BY [Microsoft.VSTS.Common.StackRank] ASC" --output table
```

**Backlog items by priority:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [Microsoft.VSTS.Common.Priority] FROM workitems WHERE [System.WorkItemType] IN ('User Story', 'Bug') AND [System.State] <> 'Closed' ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [Microsoft.VSTS.Common.StackRank] ASC" --output table
```

## Pipelines

### List pipelines

```bash
az pipelines list --output table
```

### Show recent runs

```bash
az pipelines runs list --output table
```

For a specific pipeline:
```bash
az pipelines runs list --pipeline-ids <PIPELINE_ID> --output table
```

### Trigger a pipeline run

```bash
az pipelines run --name "<Pipeline Name>" --output table
```

With a specific branch:
```bash
az pipelines run --name "<Pipeline Name>" --branch "refs/heads/main" --output table
```

### Check run status

```bash
az pipelines runs show --id <RUN_ID> --output table
```

## Repos and Pull Requests

### List pull requests

```bash
az repos pr list --output table
```

Active PRs only:
```bash
az repos pr list --status active --output table
```

### Create a pull request

```bash
az repos pr create --title "PR title" --source-branch "feature-branch" --target-branch "main" --description "PR description" --output table
```

### Show PR details

```bash
az repos pr show --id <PR_ID> --output table
```

### List PR reviewers

```bash
az repos pr reviewer list --id <PR_ID> --output table
```

## Tips

- Always use `--output table` for readable terminal output, or `--output json` when you need to parse fields programmatically.
- WIQL uses SQL-like syntax. Field names use the `[System.FieldName]` format.
- `@Me` refers to the logged-in user. `@CurrentIteration` refers to the active sprint.
- When creating or updating work items, quote values that contain spaces.
- Use `--detect true` to auto-detect organization and project from a git repo if defaults are not configured.
