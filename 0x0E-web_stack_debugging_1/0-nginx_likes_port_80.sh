#!/bin/bash

# Check Nginx configuration
nginx_config="/etc/nginx/nginx.conf"
if [ ! -f "$nginx_config" ]; then
    echo "Nginx configuration file not found at $nginx_config"
    exit 1
fi

# Verify Nginx service status
nginx_status=$(systemctl is-active nginx)
if [ "$nginx_status" != "active" ]; then
    echo "Nginx service is not running. Starting..."
    systemctl start nginx
    sleep 2  # Give some time for Nginx to start
    if [ "$(systemctl is-active nginx)" != "active" ]; then
        echo "Failed to start Nginx service. Exiting..."
        exit 1
    fi
    echo "Nginx service started successfully."
fi

# Check if anything else is listening on port 80
if netstat -tuln | grep ":80 "; then
    echo "Port 80 is already in use by another process."
    exit 1
fi

# Modify Nginx configuration to listen on port 80
if ! grep -q "listen 80;" "$nginx_config"; then
    sed -i 's/listen\s*\(.*\);/listen 80;/g' "$nginx_config"
fi

# Restart Nginx service
systemctl restart nginx
echo "Nginx is now listening on port 80."

