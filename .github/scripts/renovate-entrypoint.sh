#!/bin/bash

set -e

# Check if nix is already available
if ! command -v nix &> /dev/null; then
  echo "Installing Nix in single-user mode..."

  # Install Nix in single-user mode (no sudo required)
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

# Run renovate
exec renovate
