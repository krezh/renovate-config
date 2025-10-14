#!/bin/bash

set -e

# Source Nix if it exists
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Add Nix to PATH
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# Run renovate as the ubuntu user (default user in renovate container)
exec runuser -u ubuntu renovate
