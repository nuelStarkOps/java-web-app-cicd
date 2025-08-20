#!/bin/bash
set -euo pipefail

echo "[Start] Enabling and starting Tomcat 9..."
systemctl enable tomcat9
systemctl restart tomcat9

echo "[Start] Validating Apache config..."
apachectl configtest || { echo "Apache config invalid"; exit 1; }

echo "[Start] Enabling and starting Apache HTTPD..."
systemctl enable httpd
systemctl restart httpd

echo "[Start] Services up."