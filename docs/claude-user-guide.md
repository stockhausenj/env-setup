# Claude Code User Guide

## How to Use This Guide

Claude Code is an AI assistant that runs in your terminal. You type questions or requests in plain English, and it helps you get things done — from checking your sprint board to writing documents to reviewing pull requests.

**To start Claude Code:**

1. Open a terminal
   - On Windows: search for "Ubuntu" in the Start menu
   - On macOS: open the Terminal app (search "Terminal" in Spotlight)
2. Type `claude` and press Enter
3. You'll see a prompt where you can type your question or request
4. Type what you need, then press Enter
5. To exit, type `/exit`

**About the examples in this guide:**

Each section below includes example prompts you can type into Claude. These are starting points — you don't have to use them word-for-word. Claude understands natural language, so ask in whatever way feels natural. If Claude needs more information, it will ask you.

Claude will always show you what it's about to do (like running a command or sending a message) and ask for your confirmation before doing it.

---

## Connecting Your Accounts

Before you can use Claude with your work tools, you need to sign in to each service once. Open your terminal and run these commands.

**Azure DevOps:**

```
az login
```

This opens a browser window. Sign in with your Microsoft account. Then tell the CLI which organization and project to use by default:

```
az devops configure --defaults organization=https://dev.azure.com/YOUR-ORG project=YOUR-PROJECT
```

Replace `YOUR-ORG` and `YOUR-PROJECT` with your actual values.

**GitHub:**

```
gh auth login
```

Follow the prompts. Choose "GitHub.com", then "Login with a web browser". It will give you a code to enter in your browser.

**Confluence (Atlassian):**

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens in your browser
2. Click "Create API token" and give it a name (e.g. "Claude")
3. Copy the token

The first time you ask Claude to do something with Confluence, it will prompt you for:
- Your Atlassian site URL (e.g. `your-company.atlassian.net`)
- Your email address
- The API token you just created

You only need to do this once. Claude remembers the credentials after that.

---

## Sprint Planning and Backlog Grooming

Use Claude to quickly pull up your backlog, check sprint status, and create or move work items — all without opening the ADO web interface.

**Example prompts:**

```
Show me all unassigned items in the current sprint
```

```
What user stories are still in New state?
```

```
Help me plan next sprint — show the backlog sorted by priority
```

```
Create a user story: As a user, I want to reset my password via email
```

```
Move work item 1234 to Active and assign it to jane@company.com
```

**Tip:** Claude uses the Azure DevOps CLI under the hood. It will show you the exact command before running it, so you can see what's happening and confirm.

---

## Tracking Work and Work Items

Keep tabs on your team's work, check on bugs, add comments, and link related items.

**Example prompts:**

```
Show me my assigned work items
```

```
What bugs are currently active?
```

```
Show the details of work item 5678
```

```
Add a comment to work item 1234: Blocked waiting on API team
```

```
Link work item 1234 as a child of 5670
```

**Tip:** You can ask Claude to filter work items in many ways — by person, by state, by type, by sprint. Just describe what you're looking for.

---

## Writing and Editing Documents

Get help drafting design docs, retrospective summaries, onboarding guides, one-pagers, and other documents. Claude can also read Confluence pages and help you update them.

**Example prompts:**

```
Help me write a design doc for migrating our auth service to Azure AD
```

```
Draft a sprint retrospective summary — here are our notes: ...
```

```
Help me update our onboarding guide in Confluence
```

```
Summarize the Azure documentation for App Service deployment slots
```

```
Write a one-pager explaining our team's branching strategy
```

**Tip:** For Confluence, Claude can read and write pages directly. For Word and PowerPoint, describe what you need and Claude will draft the content — you can then paste it into the document.

---

## Reviewing Pull Requests

Have Claude review code changes, summarize what a PR does, or check if anything is waiting for your review.

**Example prompts:**

```
Review the PR at https://github.com/org/repo/pull/42
```

```
Show me the open PRs in our repo
```

```
Summarize what changed in PR #42
```

```
Are there any PRs waiting for my review?
```

**Tip:** Claude can read the full diff of a PR and give you a summary of what changed, potential issues, and whether it looks ready to merge. It can also leave review comments if you ask — but it will always confirm with you first.

---

## Checking Pipelines and Builds

Quickly check on pipeline runs, see why something failed, or trigger a new build.

**Example prompts:**

```
Show me the recent pipeline runs
```

```
What's the status of the last build?
```

```
Trigger the deploy pipeline on the main branch
```

```
Why did pipeline run 789 fail?
```

**Tip:** When a pipeline fails, Claude can look at the logs and help you figure out what went wrong.

---

## Communicating with Your Team

Send Slack messages, check what's been said in a channel, or draft announcements.

**Example prompts:**

```
Send a message to #engineering: Sprint review moved to 3pm
```

```
What were the last few messages in #incidents?
```

```
Draft a Slack message announcing our new deployment process
```

**Tip:** Claude will always show you the message and ask for your confirmation before sending anything. Nothing gets sent without your approval.

---

## Creating Diagrams and Visuals

Create architecture diagrams, flowcharts, and other visuals that you can edit and export.

**Example prompts:**

```
Draw a diagram of our deployment pipeline
```

```
Create an architecture diagram showing the API gateway, microservices, and database
```

```
Make a flowchart for our incident response process
```

```
Diagram the team's sprint workflow
```

**Tip:** Claude creates Excalidraw files. You can open them at excalidraw.com to edit, rearrange, and export as PNG or SVG for presentations.

---

## Scripting and Automation

Get help writing or fixing scripts, pipeline YAML, infrastructure templates, and other technical files.

**Example prompts:**

```
Write a PowerShell script that checks if all our Azure resources have tags
```

```
Help me fix this pipeline YAML — it's failing on the deploy stage
```

```
Convert this ARM template to Bicep
```

```
Write a bash script that backs up our database before deployment
```

**Tip:** You can point Claude at a file on your machine and ask it to fix or improve it. For example: "Look at the file deploy-pipeline.yml and tell me why the test stage is being skipped."

---

## Quick Reference

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
