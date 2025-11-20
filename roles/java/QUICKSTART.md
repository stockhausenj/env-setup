# Java Role - Quick Start Guide

## Installation

```bash
# Run your Ansible playbook
ansible-playbook -i localhost, your-playbook.yaml

# Reload your shell
source ~/.zshrc

# Verify everything works
verify-java-setup
```

## What You Get

✅ **Java 21 JDK** - Latest version via Homebrew (macOS) or direct download (Linux)
✅ **JAVA_HOME** - Automatically configured and survives upgrades
✅ **VSCode** - Pre-configured with Java settings and extension recommendations
✅ **Neovim** - Full LSP support with nvim-jdtls
✅ **IntelliJ** - JDK automatically configured
✅ **Build Tools** - Maven and Gradle memory settings optimized

## Quick Commands

```bash
# Check Java installation
java -version

# Check JAVA_HOME
echo $JAVA_HOME

# Verify complete setup
verify-java-setup

# Install VSCode extensions
cat ~/vscode-java-extensions.json | jq -r '.recommendations[]' | xargs -L 1 code --install-extension

# Update Java (macOS)
brew upgrade temurin21
```

## IDE Usage

### VSCode
1. Install recommended extensions: See `~/vscode-java-extensions.json`
2. Open a Java project
3. Extensions will auto-activate

### Neovim (LazyVim)
1. Open any `.java` file
2. LSP auto-attaches
3. Use `:Mason` to verify jdtls installation
4. Standard LSP keybindings work (gd, gr, K, etc.)

### IntelliJ IDEA
1. Open IntelliJ
2. Go to File → Project Structure → SDKs
3. Java 21 (temurin-21) should be available
4. Select it as your project SDK

## Troubleshooting

**JAVA_HOME not set?**
```bash
source ~/.zshrc
```

**Neovim LSP not working?**
```vim
:Mason
# Verify jdtls is installed
```

**VSCode not recognizing Java 21?**
1. Check VSCode settings for java.home
2. Reload window: Cmd+Shift+P → "Reload Window"

## Need Help?

- Full documentation: [README.md](./README.md)
- Detailed improvements: [IMPROVEMENTS.md](./IMPROVEMENTS.md)
- Run verification: `verify-java-setup`
