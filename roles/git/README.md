# Git Role

Ansible role for installing and configuring Git and related tools on Ubuntu and macOS.

## Description

This role handles the complete setup of a Git development environment including:
- Git installation
- Git configuration (user, aliases, colors, etc.)
- Git LFS (Large File Storage)
- diff-so-fancy for improved diff output
- Git prompt script for shell integration
- Global gitignore and gitattributes files
- Optional development tools (lazygit, search tools)

## Requirements

- Ansible 2.9 or higher
- Ubuntu or macOS operating system
- For Ubuntu: sudo privileges for package installation
- For macOS: Homebrew must be installed

## Role Variables

### Required Variables

These variables must be set when including the role:

```yaml
git_user_email: "your.email@example.com"
git_user_name: "Your Name"
```

### Optional Variables

Default values are defined in `defaults/main.yml`:

```yaml
# Feature toggles
git_install_diff_so_fancy: true      # Install diff-so-fancy for better diffs
git_install_git_lfs: true            # Install Git Large File Storage
git_install_lazygit_macos: true      # Install lazygit terminal UI on macOS
git_install_search_tools_ubuntu: true # Install ag and ugrep on Ubuntu

# Merge tool configuration
git_merge_tool_macos: opendiff       # Default merge tool for macOS
git_merge_tool_ubuntu: vimdiff       # Default merge tool for Ubuntu
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: localhost
  roles:
    - role: git
      vars:
        git_user_email: "jay.stockhausen@gmail.com"
        git_user_name: "Jay Stockhausen"
```

### Example with Custom Settings

```yaml
- hosts: localhost
  roles:
    - role: git
      vars:
        git_user_email: "jay.stockhausen@gmail.com"
        git_user_name: "Jay Stockhausen"
        git_install_lazygit_macos: false
        git_merge_tool_ubuntu: meld
```

## Files Created

This role creates the following files in your home directory:

- `~/.gitconfig` - Main Git configuration
- `~/.gitignore` - Global gitignore patterns
- `~/.gitattributes` - Global gitattributes rules
- `~/.git-prompt.sh` - Git prompt script for bash integration
- `~/.gitconfig.local` - Local overrides (not created, but referenced)

## Git Configuration Features

The deployed `.gitconfig` includes:

### Aliases
- `c` - Commit all changes with message
- `up` - Pull from remote
- `p` - Push to remote
- `s` - Status
- `co` - Checkout
- `df` - Colored diff
- `lg` - Pretty formatted log with graph
- `d` - Interactive diff with stats
- `sclone` - Shallow clone (depth=1)

### Settings
- Color-coded output for diff, status, and branch commands
- Auto-correct typos in commands
- Push to current branch by default
- Auto-prune on fetch
- Platform-specific merge tool configuration

### Local Configuration

You can create a `~/.gitconfig.local` file for machine-specific settings:

```ini
[user]
    signingkey = YOUR_GPG_KEY
[commit]
    gpgsign = true
[github]
    user = your-github-username
    token = your-token-here
```

This file is gitignored and won't be overwritten by the role.

## Installed Tools

### All Platforms
- git - Version control system
- git-lfs - Large File Storage extension
- diff-so-fancy - Improved diff output formatting

### macOS Only
- lazygit - Terminal UI for git commands

### Ubuntu Only
- silversearcher-ag (ag) - Fast code search tool
- ugrep - Ultra-fast grep alternative

## Platform Differences

### Merge Tool
- macOS uses `opendiff` by default
- Ubuntu uses `vimdiff` by default
- Can be customized via variables

### Package Management
- macOS uses Homebrew
- Ubuntu uses APT

## Notes

- The role is idempotent and can be run multiple times safely
- Existing `.gitconfig` will be overwritten - back up any custom settings to `.gitconfig.local`
- Git LFS must be initialized after installation (handled automatically)
- diff-so-fancy on Ubuntu is installed to `~/.local/bin/` - ensure this is in your PATH

## License

MIT

## Author

Jay Stockhausen
