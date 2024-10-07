#!/bin/bash

#error runtime dependency libev not found tried pkgconfig and cmake

# Function to log errors
log_error() {
    echo "[ERROR] $1" >&2
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root"
    exit 1
fi

# Trap errors and perform cleanup
trap 'log_error "An error occurred. Exiting..."; exit 1' ERR

# Function to install dependencies for Debian-based distributions
install_debian() {
    sudo apt update || { log_error "Failed to update package list"; exit 1; }
    sudo apt full-upgrade -y || { log_error "Failed to upgrade packages"; exit 1; }
    sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev \
    libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev libxext-dev meson ninja-build \
    uthash-dev cmake libxft-dev libimlib2-dev libxinerama-dev libxcb-res0-dev alsa-utils thunar feh flameshot dunst \
    rofi alacritty unzip wget curl bash-completion lightdm fastfetch || { log_error "Failed to install dependencies"; exit 1; }
    sudo apt autoremove -y || { log_error "Failed to remove unused packages"; exit 1; }
    sudo apt autoclean || { log_error "Failed to clean package cache"; exit 1; }

    # Install zoxide
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash || { log_error "Failed to install zoxide"; exit 1; }

    # Install starship
    curl -sS https://starship.rs/install.sh | sh || { log_error "Failed to install starship"; exit 1; }
}


# Function to install dependencies for Red Hat-based distributions
install_redhat() {
    sudo yum groupinstall -y "Development Tools" || { log_error "Failed to install development tools"; exit 1; }
    sudo yum install -y dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb \
    libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel meson ninja-build pcre2-devel pixman-devel \
    uthash-devel xcb-util-image-devel xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake \
    libxft-devel libimlib2-devel libxinerama-devel libxcb-res0-devel alacritty thunar feh flameshot dunst rofi \
    alsa-utils btop htop trash-cli fastfetch || { log_error "Failed to install dependencies"; }
    # Install zoxide
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash || { log_error "Failed to install zoxide"; exit 1; }

    # Install starship
    curl -sS https://starship.rs/install.sh | sh || { log_error "Failed to install starship"; exit 1; }

    sudo yum autoremove || { log_error "Failed to remove unused packages"; }
    sudo yum clean all || { log_error "Failed to clean package cache"; }
}


# Function to install dependencies for Fedora
install_fedora() {
    sudo dnf update || { log_error "Failed to update package list and installing updates"; exit 1; }
    sudo dnf groupinstall "Development Tools" || { log_error "Failed to install development tools"; exit 1; }
    sudo dnf install dbus-devel gcc git libconfig-devel libdrm-devel libev-devel libX11-devel libX11-xcb \
    libXext-devel libxcb-devel libGL-devel libEGL-devel libepoxy-devel libXft-devel imlib2-devel \
    libXinerama-devel  meson ninja-build pcre2-devel pixman-devel uthash-devel xcb-util-image-devel \
    xcb-util-renderutil-devel xorg-x11-proto-devel xcb-util-devel cmake alsa-utils thunar feh flameshot dunst \
    libXft rofi alacritty unzip wget curl bash-completion btop htop trash-cli fastfetch || { log_error "Failed to install dependencies"; }
    # Install zoxide
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

    # Install starship
    curl -sS https://starship.rs/install.sh | sh

    sudo dnf autoremove || { log_error "Failed to remove unused packages"; }
    sudo dnf clean all || { log_error "Failed to clean package cache"; }
}

# Function to install dependencies for Arch-based distributions
install_arch() {
    sudo pacman -Su --noconfirm || { log_error "Failed to update package list"; exit 1; }
    sudo pacman -S --needed --noconfirm base-devel libconfig git dbus libev libx11 libxcb libxext libgl libegl libepoxy meson pcre2 \
    pixman uthash xcb-util-image xcb-util-renderutil xorgproto cmake libxft imlib2 libxinerama xcb-util-wm xorg-xev \
    xorg-xbacklight alsa-utils thunar feh flameshot dunst rofi alacritty unzip wget curl sddm btop htop \
    bash-completion trash-cli fastfetch || { log_error "Failed to install dependencies"; exit 1; }
    # Install zoxide
    sudo pacman -S zoxide

    # Install starship
    sudo pacman -S starship
    sudo pacman -Rns "$(pacman -Qdtq)" || { log_error "Failed to remove unused packages"; }
    sudo pacman -Sc --noconfirm || { log_error "Failed to clean package cache"; exit 1; }
}

# Detect the distribution and install the appropriate packages
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu)
            echo "Detected Debian-based distribution"
            echo "Installing Dependencies using apt"
            install_debian
            ;;
        rhel|centos)
            echo "Detected Red Hat-based distribution"
            echo "Installing dependencies using Yellowdog Updater Modified"
            install_redhat
            ;;
        fedora)
            echo "Detected Fedora-based distribution"
            echo "Installing dependencies using dnf"
            install_fedora
            ;;
        arch)
            echo "Detected Arch-based distribution"
            echo "Installing packages using pacman"
            install_arch
            ;;
        *)
            log_error "Unsupported distribution"
            exit 1
            ;;
    esac
else
    log_error "/etc/os-release not found. Unsupported distribution"
    exit 1
fi

# Function to install Meslo Nerd font for dwm and Rofi icons to work
install_nerd_font() {
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_ZIP="$FONT_DIR/Meslo.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    FONT_INSTALLED=$(fc-list | grep -i "Meslo")

    # Check if Meslo Nerd-font is already installed
    if [ -n "$FONT_INSTALLED" ]; then
        echo "Meslo Nerd-fonts are already installed."
        return 0
    fi

    echo "Installing Meslo Nerd-fonts"

    # Create the fonts directory if it doesn't exist
    if [ ! -d "$FONT_DIR" ]; then
        mkdir -p "$FONT_DIR" || {
            log_error "Failed to create directory: $FONT_DIR"
            return 1
        }
    else
        echo "$FONT_DIR exists, skipping creation."
    fi

    # Check if the font zip file already exists
    if [ ! -f "$FONT_ZIP" ]; then
        # Download the font zip file
        wget -P "$FONT_DIR" "$FONT_URL" || {
            log_error "Failed to download Meslo Nerd-fonts from $FONT_URL"
            return 1
        }
    else
        echo "Meslo.zip already exists in $FONT_DIR, skipping download."
    fi

    # Unzip the font file if it hasn't been unzipped yet
    if [ ! -d "$FONT_DIR/Meslo" ]; then
        unzip "$FONT_ZIP" -d "$FONT_DIR" || {
            log_error "Failed to unzip $FONT_ZIP"
            return 1
        }
    else
        echo "Meslo font files already unzipped in $FONT_DIR, skipping unzip."
    fi

    # Remove the zip file
    rm "$FONT_ZIP" || {
        log_error "Failed to remove $FONT_ZIP"
        return 1
    }

    # Rebuild the font cache
    fc-cache -fv || {
        log_error "Failed to rebuild font cache"
        return 1
    }

    echo "Meslo Nerd-fonts installed successfully"
}

# Function to install Picom animations
picom_animations() {
    # Clone the repository in the home/build directory
    mkdir -p ~/build
    if [ ! -d ~/build/picom ]; then
        if ! git clone https://github.com/FT-Labs/picom.git ~/build/picom; then
            log_error "Failed to clone the repository"
            return 1
        fi
    else
        echo "Repository already exists, skipping clone"
    fi

    cd ~/build/picom || { log_error "Failed to change directory to picom"; return 1; }

    # Build the project
    if ! meson setup --buildtype=release build; then
        log_error "Meson setup failed"
        return 1
    fi

    if ! ninja -C build; then
        log_error "Ninja build failed"
        return 1
    fi

    # Install the built binary
    if ! sudo ninja -C build install; then
        log_error "Failed to install the built binary"
        return 1
    fi

    echo "Picom animations installed successfully"
}

# Function to clone configuration folders
clone_config_folders() {
    # Ensure the target directory exists
    [ ! -d ~/.config ] && mkdir -p ~/.config

    # Iterate over all directories in config/*
    for dir in config/*/; do
        # Extract the directory name
        dir_name=$(basename "$dir")

        # Clone the directory to ~/.config/
        if [ -d "$dir" ]; then
            cp -r "$dir" ~/.config/
            echo "Cloned $dir_name to ~/.config/"
        else
            log_error "Directory $dir_name does not exist, skipping"
        fi
    done
}

# Function to configure backgrounds
configure_backgrounds() {
    # Set the variable BG_DIR to the path where backgrounds will be stored
    BG_DIR="$HOME/Pictures/backgrounds"

    # Check if the backgrounds directory (BG_DIR) exists
    if [ ! -d "$BG_DIR" ]; then
        mkdir "$BG_DIR"
        # If the backgrounds directory doesn't exist, attempt to clone a repository containing backgrounds
        if ! git clone https://github.com/ChrisTitusTech/nord-background.git "$BG_DIR"; then
            log_error "Failed to clone the repository"
            return 1
        fi
        echo "Downloaded desktop backgrounds to $BG_DIR"
    else
        echo "Path $BG_DIR exists for desktop backgrounds, skipping download of backgrounds"
    fi
}

# Function to install slstatus
slstatus() {

    cd ~/dwm-titus-own/slstatus || { log_error "Failed to change directory to slstatus"; exit 1; }
    make || { log_error "Failed to build slstatus"; exit 1; }
    sudo make install || { log_error "Failed to install slstatus"; exit 1; }
    cd ..
}

copybashfile() {
    wget -O - https://raw.githubusercontent.com/sxyql/mybash/refs/heads/main/.bashrc | sudo tee -a ~/.bashrc /root/.bashrc > /dev/null
}

install_dwm() {
    cd ~/dwm-titus-own || { log_error "Failed to change directory to dwm"; exit 1; }
    make || { log_error "Failed to build dwm"; exit 1; }
    sudo make install || { log_error "Failed to install dwm"; exit 1; }
    cd ..
}

install_sddm() {
    sudo pacman -S sddm
    sudo systemctl enable sddm
    sudo systemctl start sddm
}

# Call the functions
install_nerd_font
clone_config_folders
picom_animations
configure_backgrounds
slstatus
copybashfile
install_dwm
install_sddm

echo "All dependencies installed successfully."