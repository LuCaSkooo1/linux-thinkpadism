#!/usr/bin/env bash

set -e
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

USERNAME=$(whoami)
BACKUP_DIR="$HOME/${USERNAME}_BACKUPS"
CONFIG_DIR="$HOME/.config"
RICE_CONFIGS="./configs"

print_txt() {
    echo -e "${2}${1}${NC}"
}


echo "
"
print_txt "【 Welcome to the Thinkpadism Setup Process. 】" "$GREEN"
print_txt " _________________________________________" "$GREEN"

echo
print_txt "Are you using Hyprland or Sway/SwayFX?" "$YELLOW"
echo "1) Hyprland"
echo "2) Sway/SwayFX"
read -p "Enter (1 or 2):" option

case $option in 
    1)
        DEPS=("hyprpaper" "nemo" "kitty" "nwg-look" "quickshell" "hyprshot" "mako" "dconf" "jq" "socat")
        WINDOW_MANAGER="Hyprland"
        ;;
    2)
        DEPS=("swaybg" "nemo" "kitty" "nwg-look" "quickshell" "grim" "slurp" "swappy" "mako" "dconf" "jq" "socat")
        WINDOW_MANAGER="Sway"
        ;;
    *)
        print_txt "Invalid option, exiting!" "$RED"
        exit 1
        ;;
esac

print_txt "You've opted to use $WINDOW_MANAGER" "$GREEN"

echo
print_txt "Verifiying existence of dependencies..." "$YELLOW"
missing_deps=()

# Best way to do this? Unsure if this has high compat
for dep in "${DEPS[@]}"; do
    if command -v "$dep" >/dev/null 2>&1 ; then
        print_txt "✓ $dep - Found." "$GREEN"
    else
        missing_deps+=("$dep")
        print_txt "✗ $dep - Not Found!" "$RED"
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo
    print_txt "Missing dependencies: ${missing_deps[*]}" "$RED"
    print_txt "Please install the required dependencies, and then run this script again." "$RED"
    
    # Some hints bcz we're nice.
    if command -v apt &> /dev/null; then
        print_txt "Hint: sudo apt install ${missing_deps[*]}" "$YELLOW"
    elif command -v pacman &> /dev/null; then
        print_txt "Hint: sudo pacman -S ${missing_deps[*]}" "$YELLOW"
    fi
    
    exit 1
fi

if [ ! -d "$RICE_CONFIGS" ]; then
    print_txt "Error: Corrupt repository! '$RICE_CONFIGS' not found! Please re-install Thinkpadism. Exiting." "$RED"
    exit 1
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo
print_txt "Copying configs for programs..." "$YELLOW"

# A bit messy, here we copy all config dirs and also detect if we need to create a backup of something.
for dir in "$RICE_CONFIGS"/*/ ; do
    if [ -d "$dir" ]; then
        dirname=$(basename "$dir")
        target_dir="$CONFIG_DIR/$dirname"
        
        # Create backup if a directory already exists.
        if [ -d "$target_dir" ]; then
            backup_target="$BACKUP_DIR/$dirname"
            print_txt "Backing up existing $dirname to $backup_target" "$YELLOW"
            
            # Append timestamp to backup, in case of multiple backups existing.
            if [ -d "$backup_target" ]; then
                timestamp=$(date +"%Y%m%d_%H%M%S")
                backup_target="${backup_target}_${timestamp}"
            fi
            
            mv "$target_dir" "$backup_target"
            print_txt "✓ Backed up $dirname" "$GREEN"
        fi
        
        # Copy config.
        cp -r "$dir" "$target_dir"
        print_txt "✓ Copied $dirname to ~/.config/" "$GREEN"
    fi
done

echo
print_txt "All configurations have been installed to ~/.config/" "$GREEN"

if [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    print_txt "Backups of existing files have been created in: $BACKUP_DIR" "$YELLOW"
fi

echo
print_txt "_____________________________________________________________________________" "$NC"
echo
print_txt "Successfully installed Thinkpadism!" "$GREEN"
print_txt "It's recommended to restart your computer, to ensure all changes take effect." "$NC"
print_txt "_____________________________________________________________________________" "$NC"