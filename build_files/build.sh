#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### 1Password (desktop app + CLI)
rpm --import https://downloads.1password.com/linux/keys/1password.asc
cat > /etc/yum.repos.d/1password.repo <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
dnf5 install -y 1password 1password-cli

# The RPM scriptlets create these groups in the image's /etc/group, but a deployed
# system keeps its own /etc/group. Declare them via sysusers.d with the same GIDs
# so they exist on every machine (needed for browser integration and `op`).
for g in onepassword onepassword-cli; do
    gid=$(getent group "$g" | cut -d: -f3)
    echo "g $g $gid" > "/usr/lib/sysusers.d/$g.conf"
done

### Brave (RPM, not Flatpak: 1Password browser integration doesn't work with Flatpak browsers)
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
curl -fsSLo /etc/yum.repos.d/brave-browser.repo \
    https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
dnf5 install -y brave-browser

### Drop third-party repos: updates arrive through image rebuilds, not on the client
rm -f /etc/yum.repos.d/1password.repo /etc/yum.repos.d/brave-browser.repo

### Services
systemctl enable tailscaled.service
