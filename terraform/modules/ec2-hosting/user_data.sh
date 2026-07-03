#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y nginx

cat > /usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>${project_name} EC2 Hosting</title>
  </head>
  <body>
    <h1>${project_name} EC2 Hosting</h1>
    <p>Nginx is running on an Amazon Linux 2023 EC2 instance.</p>
    <p>Environment: ${environment}</p>
  </body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
