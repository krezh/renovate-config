#!/bin/bash

set -e

# Check if nix is already available
if ! command -v nix &> /dev/null; then
  echo "Installing Nix..."
  # Install Nix in single-user mode (no daemon)
  sh <(curl -L https://nixos.org/nix/install) --no-daemon

  # Source the Nix profile
  if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  fi
fi

# Ensure Nix is in PATH
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# Verify nix is available
if command -v nix &> /dev/null; then
  echo "Nix is available: $(nix --version)"
else
  echo "ERROR: Nix installation failed or not found in PATH"
  exit 1
fi

# Run renovate
exec renovate
