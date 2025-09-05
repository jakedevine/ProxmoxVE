#!/usr/bin/env bash

# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Dispatcharr/Dispatcharr

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dispatcharr"
RELEASE=$(curl -s https://api.github.com/repos/Dispatcharr/Dispatcharr/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
$STD wget -q https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${RELEASE}.tar.gz
$STD tar -xzf ${RELEASE}.tar.gz
$STD mv Dispatcharr-${RELEASE} dispatcharr
$STD rm ${RELEASE}.tar.gz
cd dispatcharr
$STD chmod +x debian_install.sh
$STD ./debian_install.sh
echo "${RELEASE}" >/opt/Dispatcharr_version.txt
msg_ok "Installed Dispatcharr"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"