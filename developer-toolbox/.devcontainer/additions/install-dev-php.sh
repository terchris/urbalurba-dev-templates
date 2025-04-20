#!/bin/bash
# file: .devcontainer/additions/install-dev-php.sh
#
# Usage: ./install-dev-php.sh [options] [--version <php_version>]
#
# Options:
#   --debug     : Enable debug output for troubleshooting
#   --uninstall : Remove installed components instead of installing them
#   --force     : Force installation/uninstallation (less relevant for APT)
#   --version X.Y : Install a specific PHP major.minor version (e.g., 8.2, 8.3)
#                   Defaults to a predefined stable version if not specified.
#
# Examples:
#   ./install-dev-php.sh
#   ./install-dev-php.sh --version 8.3
#   ./install-dev-php.sh --version 8.1 --uninstall
#
#------------------------------------------------------------------------------
# CONFIGURATION - Modify this section for the PHP script
#------------------------------------------------------------------------------

# --- Script Metadata ---
SCRIPT_NAME="PHP Runtime & Development Tools"
SCRIPT_DESCRIPTION="Installs PHP runtime (CLI), common extensions, Composer, and VS Code extensions for PHP development using the Ondrej PPA."

# --- Default Configuration ---
DEFAULT_PHP_VERSION="8.3" # Specify the default PHP version to install
TARGET_PHP_VERSION=""     # Will be set based on --version flag or default

# --- Utility Functions ---
detect_architecture() {
    # Using dpkg is generally reliable on Debian/Ubuntu
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

get_installed_php_version() {
    if command -v php &> /dev/null; then
        php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;' 2>/dev/null || echo ""
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
        echo "🔧 Preparing for PHP uninstallation..."
        # Determine version to uninstall if not specified
        if [ -z "$TARGET_PHP_VERSION" ]; then
            TARGET_PHP_VERSION=$(get_installed_php_version)
            if [ -z "$TARGET_PHP_VERSION" ]; then
                echo "⚠️ Could not detect installed PHP version. Please specify with --version X.Y to uninstall."
                # Optionally, could try a generic uninstall pattern, but safer to require version.
                # exit 1 # Or proceed with a generic attempt
            else
                 echo "ℹ️ Detected PHP version $TARGET_PHP_VERSION for uninstallation."
            fi
        fi
        # Construct package list for removal (only if version is known)
        if [ -n "$TARGET_PHP_VERSION" ]; then
            declare -g PHP_APT_PACKAGES=(
                "php${TARGET_PHP_VERSION}-cli" "php${TARGET_PHP_VERSION}-common" "php${TARGET_PHP_VERSION}-curl"
                "php${TARGET_PHP_VERSION}-mbstring" "php${TARGET_PHP_VERSION}-mysql" "php${TARGET_PHP_VERSION}-pgsql"
                "php${TARGET_PHP_VERSION}-sqlite3" "php${TARGET_PHP_VERSION}-xml" "php${TARGET_PHP_VERSION}-zip"
                "php${TARGET_PHP_VERSION}-intl" "php${TARGET_PHP_VERSION}-gd" "php${TARGET_PHP_VERSION}-bcmath"
                "php${TARGET_PHP_VERSION}-opcache" "php${TARGET_PHP_VERSION}-readline"
                # Add php${TARGET_PHP_VERSION} as a meta-package sometimes used
                "php${TARGET_PHP_VERSION}"
                "composer" # Remove composer too
            )
        else
             # Attempt generic removal if version couldn't be determined
             echo "⚠️ Attempting generic PHP package removal patterns."
             declare -g PHP_APT_PACKAGES=( "php*-cli" "php*-common" "composer" ) # Minimal generic pattern
        fi

    else
        echo "🔧 Performing pre-installation setup for PHP..."
        SYSTEM_ARCH=$(detect_architecture)
        echo "🖥️ Detected system architecture: $SYSTEM_ARCH"

        # Set target PHP version (use default if --version not provided)
        if [ -z "$TARGET_PHP_VERSION" ]; then
            TARGET_PHP_VERSION="$DEFAULT_PHP_VERSION"
            echo "ℹ️ No --version specified, using default: $TARGET_PHP_VERSION"
        else
             echo "ℹ️ Target PHP version specified: $TARGET_PHP_VERSION"
        fi

        # Check if target PHP version is already installed
        local current_version=$(get_installed_php_version)
        if [[ "$current_version" == "$TARGET_PHP_VERSION" ]]; then
            echo "✅ PHP $TARGET_PHP_VERSION seems to be already installed."
            # Decide if we should exit or continue (e.g., to install extensions/composer)
            # For simplicity, we'll continue for now, apt will handle already installed packages.
        elif [ -n "$current_version" ]; then
            echo "⚠️ PHP version $current_version is installed. This script will install $TARGET_PHP_VERSION alongside it."
            echo "   You may need to use 'update-alternatives' to switch between them."
        fi

        # Check/Install software-properties-common for add-apt-repository
        if ! command -v add-apt-repository > /dev/null; then
            echo "⏳ Installing software-properties-common..."
            sudo apt-get update -y > /dev/null
            sudo apt-get install -y --no-install-recommends software-properties-common > /dev/null
        fi
        
        # Add Ondrej PHP PPA (provides up-to-date PHP versions)
        echo "➕ Adding Ondrej PHP PPA (ppa:ondrej/php)..."
        # Check if PPA is already added to avoid errors/redundancy
        if ! grep -q "^deb .*ondrej/php" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
            sudo add-apt-repository -y ppa:ondrej/php > /dev/null
        else
            echo "ℹ️ Ondrej PHP PPA already added."
        fi
        
        echo "🔄 Updating package lists after adding PPA..."
        sudo apt-get update -y > /dev/null

        # Define APT packages based on the target version
        # Using declare -g to make it globally accessible after the function returns
        declare -g PHP_APT_PACKAGES=(
            "php${TARGET_PHP_VERSION}-cli"      # Command Line Interface
            "php${TARGET_PHP_VERSION}-common"   # Common files
            "php${TARGET_PHP_VERSION}-curl"     # cURL library support
            "php${TARGET_PHP_VERSION}-mbstring" # Multibyte string support
            "php${TARGET_PHP_VERSION}-mysql"    # MySQL database support
            "php${TARGET_PHP_VERSION}-pgsql"    # PostgreSQL database support
            "php${TARGET_PHP_VERSION}-sqlite3"  # SQLite database support
            "php${TARGET_PHP_VERSION}-xml"      # XML support
            "php${TARGET_PHP_VERSION}-zip"      # ZIP archive support
            "php${TARGET_PHP_VERSION}-intl"     # Internationalization support
            "php${TARGET_PHP_VERSION}-gd"       # GD graphics library support
            "php${TARGET_PHP_VERSION}-bcmath"   # Arbitrary precision mathematics
            "php${TARGET_PHP_VERSION}-opcache"  # PHP bytecode cacher
            "php${TARGET_PHP_VERSION}-readline" # Readline support for interactive CLI
            "composer"                          # PHP Dependency Manager
            "unzip"                             # Often needed by Composer
        )
    fi
}


# --- Define VS Code extensions for PHP Development ---
declare -A EXTENSIONS # Using associative array like the C# script
EXTENSIONS["bmewburn.vscode-intelephense-client"]="PHP Intelephense|Code completion, intellisense"
EXTENSIONS["DEVSENSE.phptools-vscode"]="PHP Tools|Debugging, refactoring (often paid features)"
EXTENSIONS["xdebug.php-debug"]="PHP Debug|Xdebug integration for VS Code"
EXTENSIONS["neilbrayfield.php-docblocker"]="PHP DocBlocker|Easily add PHPDoc blocks"
EXTENSIONS["MehediDracula.php-namespace-resolver"]="PHP Namespace Resolver|Import and resolve namespaces"
EXTENSIONS["junstyle.php-cs-fixer"]="PHP CS Fixer|Code style formatting"

# --- Define verification commands ---
VERIFY_COMMANDS=(
    "command -v php >/dev/null && php --version || echo '❌ PHP CLI not found'"
    "command -v composer >/dev/null && composer --version || echo '❌ Composer not found'"
    "php -m || echo '❌ Failed to list PHP modules'" # List installed PHP modules
)

# --- Post-installation/Uninstallation Messages ---
post_installation_message() {
    local php_version
    local composer_version
    php_version=$(get_installed_php_version)
    composer_version=$(composer --version 2>/dev/null || echo "not found")

    echo
    echo "🎉 Installation process complete for: $SCRIPT_NAME (Version: ${php_version:-Target $TARGET_PHP_VERSION})!"
    echo "Purpose: $SCRIPT_DESCRIPTION"
    echo
    echo "Important Notes:"
    echo "1. PHP CLI version ${php_version:-Not detected} should be installed."
    echo "2. Composer: $composer_version"
    echo "3. Ondrej PHP PPA has been added."
    echo "4. Common PHP extensions installed (check 'php -m')."
    echo "5. VS Code extensions for PHP development suggested/installed."
    echo
    echo "Quick Start Commands:"
    echo "- Check PHP version: php --version"
    echo "- Check Composer version: composer --version"
    echo "- Run a PHP script: php your_script.php"
    echo "- Start PHP built-in server: php -S 0.0.0.0:8000 -t public/"
    echo "- Install project dependencies: composer install"
    echo "- Update dependencies: composer update"
    echo "- List installed PHP modules: php -m"
    echo
    echo "Documentation Links:"
    echo "- PHP Documentation: https://www.php.net/manual/en/"
    echo "- Composer Documentation: https://getcomposer.org/doc/"
    echo "- Ondrej PHP PPA: https://launchpad.net/~ondrej/+archive/ubuntu/php"
    echo "- PHP Intelephense Extension: https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client"
    echo "- Xdebug Extension: https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug"
    echo
    echo "Installation Status:"
    verify_installations # Re-run verification for final status
}

post_uninstallation_message() {
    echo
    echo "🏁 Uninstallation process complete for specified PHP components."
    echo
    echo "Additional Notes:"
    echo "1. If other PHP versions remain, they were not touched unless specified."
    echo "2. Composer global packages might remain in ~/.composer/vendor/bin"
    echo "3. Composer cache might remain in ~/.cache/composer"
    echo "4. The Ondrej PHP PPA was NOT removed automatically. To remove it:"
    echo "   sudo add-apt-repository --remove ppa:ondrej/php"
    echo "5. Check VS Code extensions if they need manual removal."

    # Check for remaining components (simple checks)
    echo
    echo "Checking for remaining components..."
    if command -v php >/dev/null; then
        echo "⚠️ PHP $(php --version | head -n 1) is still installed (might be a different version or not fully removed)."
    else
        echo "✅ PHP CLI appears to be removed."
    fi
    if command -v composer >/dev/null; then
        echo "⚠️ Composer $(composer --version | head -n 1) is still installed."
    else
        echo "✅ Composer appears to be removed."
    fi

    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
         local remaining_ext=0
         for ext_id in "${!EXTENSIONS[@]}"; do
             if code --list-extensions 2>/dev/null | grep -qi "^${ext_id}$"; then
                 if [ $remaining_ext -eq 0 ]; then
                      echo "⚠️ Some VS Code extensions might remain:"
                      remaining_ext=1
                 fi
                 echo "   - $ext_id"
             fi
         done
         if [ $remaining_ext -eq 1 ]; then
              echo "   Use 'code --uninstall-extension <extension_id>' to remove them."
         fi
    fi
}

# --- Custom Installation/Uninstallation Logic (using core-install-apt) ---
# No custom install function needed here, we rely on populating PHP_APT_PACKAGES
# and using the core-install-apt.sh script's functions.

#------------------------------------------------------------------------------
# STANDARD SCRIPT LOGIC - Adaptations for PHP version argument
#------------------------------------------------------------------------------

# Initialize mode flags
DEBUG_MODE=0
UNINSTALL_MODE=0
FORCE_MODE=0 # Less critical for apt, but keep for consistency

# Parse command line arguments
SCRIPT_ARGS=()
# Specific handling for --version
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG_MODE=1
            SCRIPT_ARGS+=("$1")
            shift
            ;;
        --uninstall)
            UNINSTALL_MODE=1
            SCRIPT_ARGS+=("$1")
            shift
            ;;
        --force)
            FORCE_MODE=1
            SCRIPT_ARGS+=("$1")
            shift
            ;;
        --version)
            if [[ -n "$2" && "$2" != --* ]]; then
                TARGET_PHP_VERSION="$2"
                SCRIPT_ARGS+=("$1" "$2")
                shift 2
            else
                echo "Error: --version requires a value (e.g., 8.2)" >&2
                exit 1
            fi
            ;;
        --)
            # Stop argument parsing, treat rest as potential future args if needed
            shift
            break
            ;;
        *)
            echo "Error: Unknown argument: $1" >&2
            echo "Usage: $0 [--debug] [--uninstall] [--force] [--version X.Y]"
            exit 1
            ;;
    esac
done

# Export mode flags for core scripts
export DEBUG_MODE
export UNINSTALL_MODE
export FORCE_MODE

# Source all required core installation scripts
# Adjust paths as necessary relative to this script's location
CORE_SCRIPT_DIR="$(dirname "$0")"
source "${CORE_SCRIPT_DIR}/core-install-apt.sh"
# source "${CORE_SCRIPT_DIR}/core-install-node.sh" # Not needed for PHP base install
source "${CORE_SCRIPT_DIR}/core-install-extensions.sh"
# source "${CORE_SCRIPT_DIR}/core-install-pwsh.sh" # Not needed
# source "${CORE_SCRIPT_DIR}/core-install-python-packages.sh" # Not needed

# Function to process installations using core script functions
process_installations() {
    # Process APT packages if array is defined and not empty
    if declare -p PHP_APT_PACKAGES &> /dev/null && [ ${#PHP_APT_PACKAGES[@]} -gt 0 ]; then
        # Assuming core-install-apt.sh has a function like process_apt_packages
        # Pass the *name* of the array to the function
        process_apt_packages "PHP_APT_PACKAGES"
    else
        # This case happens during uninstall if version detection failed and generic was not attempted
         if [ "${UNINSTALL_MODE}" -eq 1 ]; then
             echo "ℹ️ No specific APT packages targeted for removal (version likely undetermined)."
         else
              echo "⚠️ No APT packages defined for installation. Check pre_installation_setup."
         fi
    fi

    # Process VS Code extensions if array is not empty
    if [ ${#EXTENSIONS[@]} -gt 0 ]; then
        # Assuming core-install-extensions.sh has process_extensions
        process_extensions "EXTENSIONS"
    fi
}

# Function to verify installations
verify_installations() {
    if [ ${#VERIFY_COMMANDS[@]} -gt 0 ]; then
        echo
        echo "🔍 Verifying installations..."
        for cmd in "${VERIFY_COMMANDS[@]}"; do
            # Use eval carefully or structure commands safely
            eval "$cmd"
        done
    fi
}

# --- Main Execution Logic ---
if [ "${UNINSTALL_MODE}" -eq 1 ]; then
    echo "🔄 Starting uninstallation process for: $SCRIPT_NAME (Version: ${TARGET_PHP_VERSION:-Detected})"
    pre_installation_setup # Sets up PHP_APT_PACKAGES for removal

    # Call core script functions for uninstallation
    process_installations # Will call process_apt_packages and process_extensions in uninstall mode

    post_uninstallation_message
else
    echo "🔄 Starting installation process for: $SCRIPT_NAME (Version: ${TARGET_PHP_VERSION:-$DEFAULT_PHP_VERSION})"
    pre_installation_setup # Sets up PHP_APT_PACKAGES for installation

    # Call core script functions for installation
    process_installations # Will call process_apt_packages and process_extensions in install mode

    verify_installations
    post_installation_message
fi

echo "✅ Script execution finished."
exit 0