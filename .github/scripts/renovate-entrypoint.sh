#!/bin/bash

set -e

# If running as root, prepare /nix and switch to ubuntu user for everything else
if [ "$(id -u)" = "0" ]; then
  if ! [ -d /nix/store ]; then
    echo "Installing Lix..."

    mkdir -p /nix

    # renovate: datasource=github-releases depName=canidae-solutions/lix-quick-install-action
    RELEASE_TAG="v4.0.1"
    LIX_VERSION="2.94.0"
    url="https://github.com/canidae-solutions/lix-quick-install-action/releases/download/${RELEASE_TAG}/lix-${LIX_VERSION}-x86_64-linux.tar.zstd"

    curl -sL --retry 3 --retry-connrefused "$url" \
      | tar --skip-old-files --strip-components 1 -x -I unzstd -C /nix

    lix="$(readlink /nix/var/lix-quick-install-action/lix)"
    "$lix/bin/nix-store" --load-db < /nix/var/lix-quick-install-action/registration

    chown -R ubuntu:ubuntu /nix
  fi

  # Switch to ubuntu user and re-run this script
  exec runuser -u ubuntu "$0" "$@"
fi

# Now running as ubuntu user (owns /nix)
lix="$(readlink /nix/var/lix-quick-install-action/lix)"
MANPATH= . "$lix/etc/profile.d/nix.sh"
"$lix/bin/nix-env" -i "$lix"

# Ensure Lix is in PATH
export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"

# Configure Lix settings
export NIX_CONF_DIR="$HOME/.config/nix"
mkdir -p "$NIX_CONF_DIR"
cat > "$NIX_CONF_DIR/nix.conf" <<NIXCONF
experimental-features = nix-command flakes
accept-flake-config = true
NIXCONF

# Verify lix is available
if command -v nix &> /dev/null; then
  echo "Lix is available: $(nix --version)"
else
  echo "ERROR: Lix installation failed"
  exit 1
fi

# Run renovate
exec renovate
