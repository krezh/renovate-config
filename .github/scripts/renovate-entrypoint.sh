#!/bin/bash

set -e

# Source Nix profile if available (from mounted /nix volume)
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Add Nix to PATH
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# Verify nix is available
if command -v nix &> /dev/null; then
  echo "Nix is available: $(nix --version)"
else
  echo "WARNING: Nix not found in PATH"
fi

# Run renovate
exec renovate
