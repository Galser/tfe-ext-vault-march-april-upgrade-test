#!/usr/bin/env bash
set -x
license=$(cat /vagrant/vault.hclic)
# license
cat > /etc/vault_license.json <<EOF
{
  "text": "${license}"
}
EOF
# root token
cat > /etc/vault.d/rootTokenHeader <<EOF
X-Vault-Token: changeme
EOF
# vault-license service unit file
cat > /etc/systemd/system/vault-license.service <<EOF
[Unit]
Description=License Vault
After=vault.service
[Service]
ExecStartPre=/usr/bin/timeout 30 sh -c 'while ! /usr/bin/curl http://127.0.0.1:8200/v1/sys/health ; do sleep 2 ; done'
ExecStart=/usr/bin/curl --header @/etc/vault.d/rootTokenHeader --request PUT --data @/etc/vault_license.json http://127.0.0.1:8200/v1/sys/license
Type=oneshot
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
systemctl enable vault-license.service
systemctl start vault-license.service
systemctl status vault-license.service