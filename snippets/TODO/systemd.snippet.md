# systemd Snippets

Complete copy-paste artifacts extracted from know-how/systemd.md.

## Systemd Unit File

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My App
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/myapp --flag
Restart=on-failure
RestartSec=5
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp

[Install]
WantedBy=multi-user.target
```
