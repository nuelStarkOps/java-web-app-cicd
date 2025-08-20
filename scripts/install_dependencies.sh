#!/bin/bash
set -euo pipefail

# --- Install Java + Tomcat 9 + Apache HTTPD ---
# Use Corretto 11 (common for modern apps). If you require Java 8, switch packages accordingly.

echo "[Install] Updating packages..."
yum update -y

echo "[Install] Java (Corretto 11)..."
amazon-linux-extras enable java-openjdk11
yum install -y java-11-amazon-corretto-headless

echo "[Install] Tomcat 9..."
# On AL2, tomcat9 comes via amazon-linux-extras
amazon-linux-extras enable tomcat9
yum install -y tomcat9 tomcat9-webapps

echo "[Install] Apache HTTPD..."
yum install -y httpd

# --- Configure Apache → Tomcat reverse proxy ---
# We proxy root (/) to Tomcat app context /java-web-app/ on :8080
# (Your WAR is java-web-app.war, so the context is /java-web-app/)
cat > /etc/httpd/conf.d/tomcat_proxy.conf <<'EOF'
<VirtualHost *:80>
    ServerAdmin root@localhost
    ServerName localhost

    ProxyRequests Off
    ProxyPreserveHost On

    # Send everything at / to Tomcat context
    ProxyPass        / http://127.0.0.1:8080/java-web-app/
    ProxyPassReverse / http://127.0.0.1:8080/java-web-app/

    ErrorLog  /var/log/httpd/proxy_error.log
    CustomLog /var/log/httpd/proxy_access.log combined
</VirtualHost>
EOF

# Ensure required proxy modules are available (AL2 httpd loads these by default via conf.modules.d)
# If you customized modules, make sure mod_proxy and mod_proxy_http are loaded.

# --- Permissions sanity (Tomcat runs as 'tomcat' user) ---
# Not strictly required since CodeDeploy copies as root and Tomcat reads/expands WAR,
# but harmless if you want to be explicit:
chown -R tomcat:tomcat /usr/share/tomcat/webapps || true

echo "[Install] Done."