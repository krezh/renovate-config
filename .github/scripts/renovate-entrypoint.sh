#!/bin/bash

set -e

# Check if nix is already available
if ! command -v nix &> /dev/null; then
  echo "Installing Nix in single-user mode..."

  # Create /nix directory if running as root
  if [ "$(id -u)" = "0" ]; then
    mkdir -p /nix
    chown ubuntu:ubuntu /nix
  fi

  # Install Nix in single-user mode (no daemon)
  curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

  # Source the Nix profile
  if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
fi

# Ensure Nix is in PATH
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# Configure Nix settings
export NIX_CONF_DIR="$HOME/.config/nix"
mkdir -p "$NIX_CONF_DIR"
cat > "$NIX_CONF_DIR/nix.conf" <<EOF
experimental-features = nix-command flakes
accept-flake-config = true
EOF

# Verify nix is available
if command -v nix &> /dev/null; then
  echo "Nix is available: $(nix --version)"
else
  echo "ERROR: Nix installation failed"
  exit 1
fi

# If running as root, switch to ubuntu user to run renovate
if [ "$(id -u)" = "0" ]; then
  exec runuser -u ubuntu renovate
else
  exec renovate
fi
