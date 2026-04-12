# Claude User Guide — Design Spec

## Overview

A practical user guide for a software engineering manager explaining when and how to use Claude Code's plugins and skills for her daily work. Organized by job activity, not by tool. Includes example prompts she can copy/paste. Assumes basic terminal guidance is needed but skips setup/auth (handled separately).

## Audience

Software engineering manager. Works with Azure, ADO, GitHub, PowerPoint, Confluence, Word. Uses Teams. Does some light scripting (PowerShell, YAML pipelines, ARM/Bicep). Not a daily CLI user.

## Location

`docs/claude-user-guide.md` in the repo.

## Structure

### 1. How to Use This Guide
- What Claude Code is (1-2 sentences)
- How to open it: on WSL, search "Ubuntu" in Start menu; on macOS, open Terminal
- Type `claude` and press Enter to start
- Type your question naturally, press Enter
- To exit, type `/exit`
- How to read example prompts in this guide (they're suggestions, not exact scripts)

### 2. Sprint Planning & Backlog Grooming
**Uses:** azure-devops skill, superpowers plugin

Example prompts:
- "Show me all unassigned items in the current sprint"
- "What user stories are still in New state?"
- "Help me plan next sprint — show the backlog sorted by priority"
- "Create a user story: As a user, I want to reset my password"
- "Move work item 1234 to Active and assign it to jane@company.com"

Tips: Claude uses the `az devops` CLI under the hood. It will show you the command before running it.

### 3. Tracking Work & Work Items
**Uses:** azure-devops skill

Example prompts:
- "Show me my assigned work items"
- "What bugs are currently active?"
- "Show the details of work item 5678"
- "Add a comment to work item 1234: Blocked waiting on API team"
- "Link work item 1234 as a child of 5670"

### 4. Writing & Editing Documents
**Uses:** atlassian plugin (Confluence), microsoft-docs plugin

Example prompts:
- "Help me write a design doc for migrating our auth service to Azure AD"
- "Draft a sprint retrospective summary — here are our notes: ..."
- "Help me update our onboarding guide in Confluence"
- "Summarize the Azure documentation for App Service deployment slots"
- "Write a one-pager explaining our team's branching strategy"

Tips: Claude can read and write to Confluence pages. For Word/PowerPoint, describe what you need and Claude will help you draft the content (you paste it into the document).

### 5. Reviewing Pull Requests
**Uses:** code-review plugin, github plugin

Example prompts:
- "Review the PR at https://github.com/org/repo/pull/42"
- "Show me the open PRs in our repo"
- "Summarize what changed in PR #42"
- "Are there any PRs waiting for my review?"

Tips: Claude can read PR diffs and leave review comments. It will ask before posting anything.

### 6. Checking Pipelines & Builds
**Uses:** azure-devops skill

Example prompts:
- "Show me the recent pipeline runs"
- "What's the status of the last build?"
- "Trigger the deploy pipeline on the main branch"
- "Why did pipeline run 789 fail?"

### 7. Communicating with Your Team
**Uses:** slack plugin

Example prompts:
- "Send a message to #engineering: Sprint review moved to 3pm"
- "What were the last few messages in #incidents?"
- "Draft a Slack message announcing our new deployment process"

Tips: Claude will always show you the message before sending and ask for confirmation.

### 8. Creating Diagrams & Visuals
**Uses:** excalidraw-diagram-skill

Example prompts:
- "Draw a diagram of our deployment pipeline"
- "Create an architecture diagram showing the API gateway, microservices, and database"
- "Make a flowchart for our incident response process"
- "Diagram the team's sprint workflow"

Tips: Claude creates Excalidraw files you can open in excalidraw.com to edit and export.

### 9. Scripting & Automation
**Uses:** Built-in Claude capabilities

Example prompts:
- "Write a PowerShell script that checks if all our Azure resources have tags"
- "Help me fix this pipeline YAML — it's failing on the deploy stage"
- "Convert this ARM template to Bicep"
- "Write a bash script that backs up our database before deployment"

Tips: Claude can read and edit files directly. Point it at a file and ask it to fix or improve it.

### 10. Quick Reference Table

| I want to... | Ask Claude... |
|---|---|
| See my sprint work | "Show my assigned items in the current sprint" |
| Create a work item | "Create a bug: Login page returns 500 on empty email" |
| Check pipeline status | "Show recent pipeline runs" |
| Review a PR | "Review PR #42" |
| Write a document | "Help me draft a design doc for ..." |
| Update Confluence | "Help me update our runbook in Confluence" |
| Send a Slack message | "Send a message to #team: ..." |
| Create a diagram | "Draw an architecture diagram of ..." |
| Fix a script | "This pipeline YAML is failing — help me fix it" |
| Look up Azure docs | "How do I configure Azure App Service custom domains?" |
