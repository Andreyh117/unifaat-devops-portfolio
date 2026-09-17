#!/bin/bash
set -euxo pipefail
exec > >(tee -a /var/log/technova-setup.log) 2>&1
dnf install -y git tar xz
# Versão 18 exigida pelo TF, independente do Node padrão da AMI.
cd /tmp
curl -fsSLO https://nodejs.org/dist/v18.20.8/node-v18.20.8-linux-x64.tar.xz
curl -fsSLO https://nodejs.org/dist/v18.20.8/SHASUMS256.txt
grep ' node-v18.20.8-linux-x64.tar.xz$' SHASUMS256.txt | sha256sum -c -
tar -xJf node-v18.20.8-linux-x64.tar.xz -C /usr/local --strip-components=1
export PATH=/usr/local/bin:$PATH
node --version | grep '^v18\.'
mkdir -p /opt/technova-api
cd /opt/technova-api
# Versão simplificada permitida pelo TF e pelo laboratório.
cat > package.json <<'JSON'
{"name":"technova-api","version":"1.0.0","private":true,"scripts":{"start":"node server.js"},"dependencies":{"express":"4.21.2"}}
JSON
cat > server.js <<'JS'
const express = require('express');
const app = express();
app.get('/', (_req, res) => res.json({name: 'TechNova API', aula: '04'}));
app.get('/health', (_req, res) => res.json({status: 'ok'}));
app.get('/orders', (_req, res) => res.json([]));
app.listen(3000, '0.0.0.0');
JS
npm install
chown -R ec2-user:ec2-user /opt/technova-api
cat > /etc/systemd/system/technova-api.service <<'UNIT'
[Unit]
Description=TechNova API
After=network.target
[Service]
User=ec2-user
WorkingDirectory=/opt/technova-api
ExecStart=/usr/local/bin/node server.js
Restart=on-failure
[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now technova-api
