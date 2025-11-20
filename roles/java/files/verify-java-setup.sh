#!/bin/bash
# Java Development Environment Verification Script
# Run this after installing the Java role to verify everything is configured correctly

set -e

echo "======================================"
echo "Java Development Environment Check"
echo "======================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check functions
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

check_env_var() {
    if [ -n "${!1}" ]; then
        echo -e "${GREEN}✓${NC} $1 is set: ${!1}"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not set"
        return 1
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} File exists: $1"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} File not found: $1"
        return 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Directory exists: $1"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Directory not found: $1"
        return 1
    fi
}

# 1. Check Java installation
echo "1. Checking Java Installation..."
if check_command java; then
    java -version 2>&1 | head -n 3
    echo ""
fi

# 2. Check JAVA_HOME
echo "2. Checking JAVA_HOME..."
check_env_var JAVA_HOME
if [ -n "$JAVA_HOME" ]; then
    check_dir "$JAVA_HOME"
fi
echo ""

# 3. Check Java in PATH
echo "3. Checking Java in PATH..."
if [ -n "$JAVA_HOME" ] && [[ ":$PATH:" == *":$JAVA_HOME/bin:"* ]]; then
    echo -e "${GREEN}✓${NC} JAVA_HOME/bin is in PATH"
else
    echo -e "${RED}✗${NC} JAVA_HOME/bin is not in PATH"
fi
echo ""

# 4. Check shell configuration
echo "4. Checking Shell Configuration..."
check_file "$HOME/.sources/java"
if [ -f "$HOME/.sources/java" ]; then
    echo "Content of ~/.sources/java:"
    cat "$HOME/.sources/java"
fi
echo ""

# 5. Check IDE configurations
echo "5. Checking IDE Configurations..."

# VSCode
if [ "$(uname)" == "Darwin" ]; then
    check_file "$HOME/Library/Application Support/Code/User/java-settings.json"
else
    check_file "$HOME/.config/Code/User/java-settings.json"
fi

# Neovim
check_file "$HOME/.config/nvim/lua/plugins/java-lsp.lua"

echo ""

# 6. Check build tools (optional)
echo "6. Checking Build Tools (optional)..."
if check_command mvn; then
    mvn -version 2>&1 | head -n 1
fi

if check_command gradle; then
    gradle -version 2>&1 | grep "Gradle" | head -n 1
fi
echo ""

# 7. Platform-specific checks
echo "7. Platform-Specific Checks..."
if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: macOS"
    if command -v /usr/libexec/java_home &> /dev/null; then
        echo -e "${GREEN}✓${NC} java_home utility available"
        /usr/libexec/java_home -V 2>&1 || true
    fi

    # Check if Homebrew temurin21 is installed
    if command -v brew &> /dev/null; then
        if brew list --cask temurin21 &> /dev/null; then
            echo -e "${GREEN}✓${NC} temurin21 is installed via Homebrew"
        else
            echo -e "${YELLOW}⚠${NC} temurin21 is not installed via Homebrew"
        fi
    fi
else
    echo "Platform: Linux"
    check_dir "/opt/jdk-21*" 2>/dev/null || echo -e "${YELLOW}⚠${NC} No JDK found in /opt/"
fi
echo ""

# 8. Test Java compilation and execution
echo "8. Testing Java Compilation and Execution..."
TEST_DIR=$(mktemp -d)
cat > "$TEST_DIR/HelloWorld.java" << 'EOF'
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Java " + System.getProperty("java.version") + " is working!");
        System.out.println("JAVA_HOME: " + System.getenv("JAVA_HOME"));
    }
}
EOF

cd "$TEST_DIR"
if javac HelloWorld.java 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Java compilation successful"
    if java HelloWorld 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Java execution successful"
    else
        echo -e "${RED}✗${NC} Java execution failed"
    fi
else
    echo -e "${RED}✗${NC} Java compilation failed"
fi
rm -rf "$TEST_DIR"
echo ""

# Summary
echo "======================================"
echo "Verification Complete!"
echo "======================================"
echo ""
echo "If you see any errors above, please:"
echo "1. Source your shell configuration: source ~/.zshrc or source ~/.bash_profile"
echo "2. Check the Java role README for troubleshooting"
echo "3. Verify the Ansible playbook ran successfully"
