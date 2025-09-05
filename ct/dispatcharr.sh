#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/jakedevine/ProxmoxVE/dispatcharr/misc/build.func)
# Copyright (c) 2021-2024 community-scripts ORG
# Author: 
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Dispatcharr/Dispatcharr

# App Default Values
APP="Dispatcharr"
var_tags="iptv;stream"
var_cpu="2"
var_ram="2048"
var_disk="8"
var_os="ubuntu"
var_version="22.04"
var_unprivileged="1"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /home/dispatcharr ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/Dispatcharr/Dispatcharr/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop dispatcharr dispatcharr-websocket
    msg_ok "Stopped ${APP}"

    msg_info "Updating ${APP} to ${RELEASE}"
    cd /home/dispatcharr/dispatcharr
    sudo -u dispatcharr git fetch --all
    sudo -u dispatcharr git reset --hard origin/main
    sudo -u dispatcharr venv/bin/pip install -r requirements.txt
    if [[ -d frontend ]]; then
      cd frontend
      sudo -u dispatcharr npm install
      sudo -u dispatcharr npm run build
      cd ..
    fi
    sudo -u dispatcharr bash -c "source venv/bin/activate && python manage.py migrate --noinput"
    sudo -u dispatcharr bash -c "source venv/bin/activate && python manage.py collectstatic --noinput"
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP}"

    msg_info "Starting ${APP}"
    systemctl start dispatcharr dispatcharr-websocket
    msg_ok "Started ${APP}"
    msg_ok "Updated Successfully"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}."
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9191${CL}"