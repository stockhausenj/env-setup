# Java Development Environment Setup

This Ansible role installs and configures Java 21 JDK for development across macOS and Linux platforms, with IDE integration for VSCode, Neovim (LazyVim), and IntelliJ IDEA.

## Features

- **Cross-platform support**: macOS (Homebrew) and Linux (direct download)
- **Latest Java 21**: Automatically installs the latest Java 21 JDK
- **Dynamic JAVA_HOME**: Automatically detects installed Java version
- **IDE Integration**: Pre-configured settings for VSCode, Neovim, and IntelliJ
- **Build tool support**: Pre-configured Maven and Gradle settings

## Installation

### macOS
Uses Homebrew to install Eclipse Temurin 21 (AdoptOpenJDK):
```bash
brew install --cask temurin21
```

### Linux
Downloads the latest OpenJDK 21 from java.net and installs to `/opt/`

## Environment Variables

The role configures the following environment variables in `~/.sources/java`:

- `JAVA_HOME`: Path to Java installation
- `PATH`: Adds Java binaries to PATH
- `MAVEN_OPTS`: Maven JVM options (2GB heap)
- `GRADLE_OPTS`: Gradle JVM options (daemon mode)

## IDE Configuration

### VSCode
- Creates `java-settings.json` with Java 21 runtime configuration
- Recommended extensions list in `vscode-java-extensions.json`
- Install extensions with:
  ```bash
  cat vscode-java-extensions.json | jq -r '.recommendations[]' | xargs -L 1 code --install-extension
  ```

### Neovim (LazyVim)
- Configures `nvim-jdtls` for Java LSP support
- Installs via Mason: jdtls, java-test, java-debug-adapter
- Includes:
  - Code completion and navigation
  - Debugging support
  - Test runner integration
  - Code formatting (Google Java Style)
  - Lombok support

To use in Neovim:
1. Open a Java file
2. LSP will auto-attach
3. Use standard LazyVim LSP keybindings

### IntelliJ IDEA
- Configures JDK table with Java 21
- Automatically detects IntelliJ version
- Can be overridden with `intellij_version` variable

## Upgrading Java

### macOS
```bash
brew upgrade temurin21
```
The `JAVA_HOME` environment variable will automatically point to the new version.

### Linux
Re-run the Ansible playbook to download and install the latest version.

## Verification

After installation, verify your setup:

```bash
# Check Java version
java -version

# Check JAVA_HOME
echo $JAVA_HOME

# Check Maven (if installed)
mvn -version

# Check Gradle (if installed)
gradle -version
```

## Customization

### Variables
- `intellij_version`: IntelliJ IDEA version (default: "2024.1")
- `node_version`: For Node.js-based Java tools

### Adding Additional JDKs

For macOS, you can install multiple JDK versions:
```bash
brew install --cask temurin17  # Java 17
brew install --cask temurin21  # Java 21
```

Switch between versions:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)  # Use Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 21)  # Use Java 21
```

## Troubleshooting

### macOS: JAVA_HOME not found
If `/usr/libexec/java_home` fails:
1. Ensure Java is installed: `brew list --cask temurin21`
2. Check available versions: `/usr/libexec/java_home -V`
3. Manually set: `export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home`

### Linux: Java not in PATH
1. Source your shell profile: `source ~/.bash_profile` or `source ~/.zshrc`
2. Check `.sources/java` exists: `cat ~/.sources/java`
3. Verify sourcing is configured in your shell rc file

### Neovim: JDTLS not working
1. Ensure Mason installed packages: `:Mason`
2. Check for Java files in project: Must have `pom.xml` or `build.gradle`
3. Check LSP logs: `:LspLog`
4. Restart LSP: `:LspRestart`

### VSCode: Java extension not using Java 21
1. Check settings: `Cmd+,` → search "java.home"
2. Verify path in `java-settings.json`
3. Reload window: `Cmd+Shift+P` → "Reload Window"

## Additional Resources

- [Eclipse Temurin](https://adoptium.net/)
- [OpenJDK 21](https://jdk.java.net/21/)
- [nvim-jdtls Documentation](https://github.com/mfussenegger/nvim-jdtls)
- [VSCode Java Extension Pack](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack)
