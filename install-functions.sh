#!/usr/bin/env bash

# Installation script for shell functions
# This script helps set up shell functions in your environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_FUNCTIONS_DIR="${SCRIPT_DIR}/shell-functions"

echo "=========================================="
echo "  Shell Functions Installation Script"
echo "=========================================="
echo ""

# Detect shell
if [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
    RC_FILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
    RC_FILE="$HOME/.zshrc"
else
    echo "Warning: Unsupported shell. Please manually source the functions."
    SHELL_TYPE="unknown"
fi

echo "Detected shell: $SHELL_TYPE"
echo "RC file: $RC_FILE"
echo ""

# Check if functions directory exists
if [ ! -d "$SHELL_FUNCTIONS_DIR" ]; then
    echo "Error: shell-functions directory not found!"
    echo "Expected location: $SHELL_FUNCTIONS_DIR"
    exit 1
fi

echo "Shell functions directory: $SHELL_FUNCTIONS_DIR"
echo ""

# List available function files
echo "Available function files:"
for file in "$SHELL_FUNCTIONS_DIR"/*.sh; do
    if [ -f "$file" ]; then
        basename "$file"
    fi
done
echo ""

# Installation options
echo "Installation options:"
echo "1) Add to shell RC file (recommended)"
echo "2) Source for current session only"
echo "3) Show manual installation instructions"
echo "4) Exit"
echo ""

read -p "Select an option (1-4): " choice

case $choice in
    1)
        if [ "$SHELL_TYPE" = "unknown" ]; then
            echo "Error: Cannot auto-install for unknown shell"
            exit 1
        fi

        # Check if already installed
        if grep -q "the-book-of-secret-knowledge/shell-functions" "$RC_FILE" 2>/dev/null; then
            echo ""
            echo "Shell functions appear to already be configured in $RC_FILE"
            read -p "Overwrite existing configuration? (y/n): " overwrite
            if [ "$overwrite" != "y" ]; then
                echo "Installation cancelled."
                exit 0
            fi
        fi

        # Remove any existing shell-functions block to avoid duplicates
        if [ -f "$RC_FILE" ]; then
            tmp_rc_file="${RC_FILE}.tmp.$$"
            awk '
                BEGIN { skip = 0 }
                $0 == "# Shell functions from the-book-of-secret-knowledge" {
                    skip = 1
                    next
                }
                skip && /^fi$/ {
                    skip = 0
                    next
                }
                skip { next }
                { print }
            ' "$RC_FILE" > "$tmp_rc_file" && mv "$tmp_rc_file" "$RC_FILE"
        fi

        # Add to RC file
        cat >> "$RC_FILE" <<EOF

# Shell functions from the-book-of-secret-knowledge
# Added on $(date)
if [ -d "$SHELL_FUNCTIONS_DIR" ]; then
  for func_file in "$SHELL_FUNCTIONS_DIR"/*.sh; do
    [ -f "\$func_file" ] && source "\$func_file"
  done
fi
EOF
        echo ""
        echo "✓ Successfully added to $RC_FILE"
        echo ""
        echo "To activate in current session, run:"
        echo "  source $RC_FILE"
        echo ""
        echo "Or open a new terminal window."
        ;;

    2)
        echo ""
        echo "Sourcing functions for current session..."
        for file in "$SHELL_FUNCTIONS_DIR"/*.sh; do
            if [ -f "$file" ]; then
                source "$file"
                echo "✓ Sourced $(basename "$file")"
            fi
        done
        echo ""
        echo "Functions are now available in this terminal session."
        echo "They will not persist after closing this terminal."
        ;;

    3)
        echo ""
        echo "=========================================="
        echo "  Manual Installation Instructions"
        echo "=========================================="
        echo ""
        echo "Add the following to your ~/.bashrc or ~/.zshrc:"
        echo ""
        echo "# Shell functions from the-book-of-secret-knowledge"
        echo "if [ -d \"$SHELL_FUNCTIONS_DIR\" ]; then"
        echo "  for func_file in \"$SHELL_FUNCTIONS_DIR\"/*.sh; do"
        echo "    [ -f \"\$func_file\" ] && source \"\$func_file\""
        echo "  done"
        echo "fi"
        echo ""
        echo "Then reload your shell:"
        echo "  source ~/.bashrc   # for bash"
        echo "  source ~/.zshrc    # for zsh"
        echo ""
        ;;

    4)
        echo "Installation cancelled."
        exit 0
        ;;

    *)
        echo "Invalid option. Installation cancelled."
        exit 1
        ;;
esac

echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "For documentation, see: $SHELL_FUNCTIONS_DIR/README.md"
echo "Function categories:"
echo "  - Network functions (DomainResolve, CheckPort, GetPublicIP, etc.)"
echo "  - System functions (SysInfo, TopMemory, CheckService, etc.)"
echo "  - File functions (FindDuplicates, BulkRename, Extract, etc.)"
echo "  - Git functions (gs, glog, GitStats, etc.)"
echo "  - Docker functions (DockerStats, DockerClean, etc.)"
echo "  - Security functions (AuditPorts, CheckFirewall, SecurityReport, etc.)"
echo ""
