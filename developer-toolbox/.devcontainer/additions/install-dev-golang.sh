#!/bin/bash
# file: .devcontainer/additions/install-dev-golang.sh
#
# Usage: ./install-dev-golang.sh [options] [--version <go_version>]
#
# Options:
#   --debug     : Enable debug output for troubleshooting
#   --uninstall : Remove installed components instead of installing them
#   --force     : Force installation/uninstallation
#   --version X.Y.Z : Install a specific Go version (e.g., 1.21.0)
#                     Defaults to a predefined stable version if not specified.
#
# Examples:
#   ./install-dev-golang.sh
#   ./install-dev-golang.sh --version 1.21.0
#   ./install-dev-golang.sh --version 1.20.0 --uninstall
#
#------------------------------------------------------------------------------
# CONFIGURATION - Modify this section for the Go script
#------------------------------------------------------------------------------

# --- Script Metadata ---
SCRIPT_NAME="Go Runtime & Development Tools"
SCRIPT_DESCRIPTION="Installs Go runtime, common tools, and VS Code extensions for Go development."

# --- Default Configuration ---
DEFAULT_GO_VERSION="1.21.0" # Specify the default Go version to install
TARGET_GO_VERSION=""        # Will be set based on --version flag or default

# --- Utility Functions ---
detect_architecture() {
    if command -v dpkg > /dev/null 2>&1; then
        ARCH=$(dpkg --print-architecture)
    elif command -v uname > /dev/null 2>&1; then
        local unamem=$(uname -m)
        case "$unamem" in
            aarch64|arm64) ARCH="arm64" ;;
            x86_64) ARCH="amd64" ;;
            *) ARCH="$unamem" ;;
        esac
    else
        ARCH="unknown"
    fi
    echo "$ARCH"
}

get_installed_go_version() {
    if command -v go > /dev/null; then
        go version | grep -oP 'go\K[0-9.]+'
    else
        echo ""
    fi
}

# --- Pre-installation/Uninstallation Setup ---
pre_installation_setup() {
    echo "🔧 Preparing environment..."
    
    # Ensure essential tools are present
    if ! command -v sudo > /dev/null || ! command -v apt-get > /dev/null || ! command -v curl > /dev/null || ! command -v gpg > /dev/null; then
         echo "⏳ Installing prerequisites (sudo, curl, apt-transport-https, gpg)..."
         apt-get update -y > /dev/null
         apt-get install -y --no-install-recommends sudo curl apt-transport-https ca-certificates gnupg > /dev/null
    fi

    if [ "${UNINSTALL_MODE}" -eq 1 ]; then
        echo "🔧 Preparing for Go uninstallation..."
        if [ -z "$TARGET_GO_VERSION" ]; then
            TARGET_GO_VERSION=$(get_installed_go_version)
            if [ -z "$TARGET_GO_VERSION" ]; then
                echo "⚠️ Could not detect installed Go version. Please specify with --version X.Y.Z to uninstall."
                exit 1
            else
                echo "ℹ️ Detected Go version $TARGET_GO_VERSION for uninstallation."
            fi
        fi

        declare -g GO_PACKAGES=(
            "golang-go"
            "golang-go.tools"
            "golang-golang-x-tools"
        )
    else
        echo "🔧 Performing pre-installation setup for Go..."
        SYSTEM_ARCH=$(detect_architecture)
        echo "🖥️ Detected system architecture: $SYSTEM_ARCH"

        if [ -z "$TARGET_GO_VERSION" ]; then
            TARGET_GO_VERSION="$DEFAULT_GO_VERSION"
            echo "ℹ️ No --version specified, using default: $TARGET_GO_VERSION"
        else
            echo "ℹ️ Target Go version specified: $TARGET_GO_VERSION"
        fi

        local current_version=$(get_installed_go_version)
        if [[ "$current_version" == "$TARGET_GO_VERSION" ]]; then
            echo "✅ Go $TARGET_GO_VERSION seems to be already installed."
        elif [ -n "$current_version" ]; then
            echo "⚠️ Go version $current_version is installed. This script will install $TARGET_GO_VERSION alongside it."
            echo "   You may need to update your PATH to use the new version."
        fi

        # Set up Go installation directory
        GO_INSTALL_DIR="/usr/local/go"
        GO_BIN_DIR="/usr/local/go/bin"
        
        # Add Go binary directory to PATH if not already present
        if ! grep -q "$GO_BIN_DIR" ~/.bashrc; then
            echo "export PATH=\$PATH:$GO_BIN_DIR" >> ~/.bashrc
            source ~/.bashrc
        fi
    fi
}

# --- Define VS Code extensions for Go Development ---
declare -A EXTENSIONS
EXTENSIONS["golang.go"]="Go|Core Go language support"
EXTENSIONS["premparihar.gotestexplorer"]="Go Test Explorer|Test runner and debugger"
EXTENSIONS["zxh404.vscode-proto3"]="Protocol Buffers|Protocol Buffer support"
EXTENSIONS["redhat.vscode-yaml"]="YAML|YAML support for Go configuration"
EXTENSIONS["ms-azuretools.vscode-docker"]="Docker|Docker support for Go applications"

# --- Define verification commands ---
VERIFY_COMMANDS=(
    "command -v go >/dev/null && go version || echo '❌ Go not found'"
    "go env || echo '❌ Failed to get Go environment'"
    "go list -m all || echo '❌ Failed to list Go modules'"
)

# --- Post-installation/Uninstallation Messages ---
post_installation_message() {
    local go_version
    go_version=$(go version 2>/dev/null || echo "not found")

    echo
    echo "🎉 Installation process complete for: $SCRIPT_NAME!"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    echo
    echo "Important Notes:"
    echo "1. Go: $go_version"
    echo "2. Go workspace: $GOPATH"
    echo "3. VS Code extensions for Go development suggested/installed."
    echo
    echo "Quick Start Commands:"
    echo "- Check Go version: go version"
    echo "- Check Go environment: go env"
    echo "- Create new module: go mod init example.com/hello"
    echo "- Build program: go build"
    echo "- Run program: go run main.go"
    echo "- Test program: go test ./..."
    echo "- Install dependencies: go get ./..."
    echo
    echo "Documentation Links:"
    echo "- Go Documentation: https://golang.org/doc/"
    echo "- Go Modules: https://golang.org/ref/mod"
    echo "- Go Standard Library: https://pkg.go.dev/std"
    echo "- VS Code Go Extension: https://marketplace.visualstudio.com/items?itemName=golang.go"
    echo
    echo "Installation Status:"
    verify_installations
}

post_uninstallation_message() {
    echo
    echo "🏁 Uninstallation process complete for specified Go components."
    echo
    echo "Additional Notes:"
    echo "1. If other Go versions remain, they were not touched unless specified."
    echo "2. Go workspace and modules might remain in $GOPATH"
    echo "3. Check VS Code extensions if they need manual removal."

    echo
    echo "Checking for remaining components..."
    if command -v go >/dev/null; then
        echo "⚠️ Go $(go version) is still installed."
    else
        echo "✅ Go appears to be removed."
    fi

    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        local remaining_ext=0
        for ext_id in "${!EXTENSIONS[@]}"; do
            if code --list-extensions 2>/dev/null | grep -qi "^${ext_id}$"; then
                if [ $remaining_ext -eq 0 ]; then
                    echo "⚠️ Some VS Code extensions might remain:"
                fi
                echo "   - ${EXTENSIONS[$ext_id]%%|*}"
                ((remaining_ext++))
            fi
        done
        if [ $remaining_ext -eq 0 ]; then
            echo "✅ No VS Code extensions remain."
        fi
    fi
}

# --- Main Script Logic ---
# (Include the common script logic from the PHP script here)
# This includes argument parsing, installation/uninstallation functions,
# and the main execution flow.

# Note: The actual implementation of the common script logic would be shared
# across all installation scripts. For brevity, it's not repeated here. 