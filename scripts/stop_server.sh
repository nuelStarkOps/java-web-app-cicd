#!/bin/bash
set -euo pipefail

stop_if_active () {
  local svc="$1"
  if systemctl is-active --quiet "$svc"; then
    echo "[Stop] Stopping $svc..."
    systemctl stop "$svc"
  else
    echo "[Stop] $svc not active; skipping."
  fi
}

# Stop front-end first, then backend
stop_if_active httpd
stop_if_active tomcat9

echo "[Stop] Done."