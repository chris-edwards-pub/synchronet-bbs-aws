# Synchronet BBS Ansible Deployment

This repository contains modular Ansible playbooks for deploying a complete Synchronet BBS system with MQTT support, SSL certificates, and Nginx reverse proxy.

## Structure

The deployment has been broken down into logical, modular components:

### Core Playbooks

- **`main.yaml`** - Main orchestration playbook that runs all components in the correct order
- **`user-setup.yaml`** - Creates users, groups, and configures sudo access
- **`system-dependencies.yaml`** - Installs packages, configures Docker, SSH, and system settings
- **`mosquitto-setup.yaml`** - Sets up Mosquitto MQTT broker in Docker with authentication
- **`ssl-certificates.yaml`** - Generates self-signed certificates and manages Let's Encrypt certificates
- **`synchronet-build.yaml`** - Builds and installs Synchronet BBS from source
- **`logging-config.yaml`** - Configures rsyslog and logrotate for BBS and MQTT logs
- **`nginx-proxy.yaml`** - Sets up Nginx reverse proxy with SSL termination

### Legacy Files

- **`install_synchronet.yaml`** - Original monolithic playbook (kept for reference)

### Support Files

- **`run_playbook.sh`** - Enhanced deployment script with component selection
- **`templates/sbbs.service.j2`** - Systemd service template for Synchronet

## Usage

### Quick Start (Complete Installation)

```bash
# Run the complete installation
./run_playbook.sh

# Or explicitly specify full installation
./run_playbook.sh --full
```

### Component-Based Installation

```bash
# List available components
./run_playbook.sh --list-components

# Run specific component
./run_playbook.sh --component users
./run_playbook.sh --component system
./run_playbook.sh --component synchronet

# Skip inventory download (use existing hosts.ini)
./run_playbook.sh --skip-download
```

### Command Line Options

```bash
./run_playbook.sh [OPTIONS]

Options:
  -h, --help              Show help message
  -f, --full              Run complete installation (default)
  -c, --component NAME    Run specific component only
  --list-components       List available components
  --skip-download         Skip inventory download (use existing hosts.ini)
```

## Components Description

### 1. User Setup (`user-setup.yaml`)
- Creates `sbbs` and `mosquitto` system users
- Configures groups and permissions
- Sets up passwordless sudo for sbbs user

### 2. System Dependencies (`system-dependencies.yaml`)
- Installs development tools, libraries, and system packages
- Configures Docker service
- Sets up SSH timeouts and timezone
- Installs Python packages for certificate management

### 3. Mosquitto Setup (`mosquitto-setup.yaml`)
- Creates Docker volumes and configuration directories
- Runs Mosquitto MQTT broker in Docker
- Sets up authentication with password file
- Configures listeners for MQTT and WebSocket (TLS and non-TLS)

### 4. SSL Certificates (`ssl-certificates.yaml`)
- Generates self-signed CA and server certificates
- Obtains Let's Encrypt certificates via Certbot
- Sets up automatic certificate renewal
- Copies certificates for MQTT broker use

### 5. Synchronet Build (`synchronet-build.yaml`)
- Clones Synchronet source code
- Builds BBS from source with all components
- Creates systemd service
- Configures for reverse proxy (port 8080)
- Copies MQTT certificates to BBS directory

### 6. Logging Configuration (`logging-config.yaml`)
- Configures rsyslog for BBS logging
- Sets up logrotate for log management
- Creates proper log file permissions

### 7. Nginx Proxy (`nginx-proxy.yaml`)
- Configures Nginx as reverse proxy
- Sets up SSL termination with Let's Encrypt
- Configures security headers
- Handles WebSocket upgrades for modern BBS features

## Prerequisites

### Local Machine
- Ansible installed
- AWS CLI configured (for inventory download)
- SSH key access to target servers

### Target Servers
- RHEL/CentOS/Rocky Linux 8+
- Root or sudo access
- Internet connectivity for package installation

## Configuration Variables

Key variables used across playbooks:

```yaml
sbbs_user: sbbs                              # BBS system user
sbbs_home: /home/{{ sbbs_user }}            # User home directory
sbbs_dir: "{{ sbbs_home }}/sbbs"            # BBS installation directory
repo_dir: "{{ sbbs_dir }}/repo"             # Source code directory
```

## Deployment Flow

When running the complete installation, components execute in this order:

1. **User Setup** - Create necessary users and groups
2. **System Dependencies** - Install packages and configure system
3. **Mosquitto Setup** - Deploy MQTT broker with Docker
4. **SSL Certificates** - Generate and configure certificates
5. **Synchronet Build** - Build and install BBS software
6. **Logging Configuration** - Set up log management
7. **Nginx Proxy** - Configure reverse proxy and SSL termination

## Security Features

- Let's Encrypt SSL certificates with automatic renewal
- Nginx reverse proxy with security headers
- MQTT broker with authentication
- Passwordless sudo configured securely
- Proper file permissions and ownership
- Self-signed certificates for internal MQTT communication

## Monitoring and Maintenance

### Log Locations
- BBS Logs: `/var/log/sbbs.log`
- MQTT Logs: `/var/log/mosquitto/mosquitto.log`
- Nginx Logs: `/var/log/nginx/`

### Service Management
```bash
# Check service status
systemctl status sbbs nginx docker

# Check MQTT container
docker ps --filter name=mosquitto

# View logs
journalctl -u sbbs -f
tail -f /var/log/sbbs.log
```

### Certificate Renewal
- Automatic renewal via systemd timer: `renew-nginx-ssl.timer`
- Manual renewal: `/usr/local/bin/renew-nginx-ssl.sh`

## Troubleshooting

### Common Issues

1. **Certificate Generation Fails**
   - Check DNS resolution for `bbs.c64.pub`
   - Ensure ports 80/443 are accessible
   - Verify email address in certificate configuration

2. **MQTT Connection Issues**
   - Check Docker container status: `docker ps`
   - Verify port accessibility: `telnet localhost 1883`
   - Check MQTT logs: `docker logs mosquitto`

3. **BBS Build Fails**
   - Ensure development tools are installed
   - Check available disk space
   - Review build logs in `/home/sbbs/sbbs/repo/src/sbbs3/`

4. **Nginx Proxy Issues**
   - Test configuration: `nginx -t`
   - Check certificate paths and permissions
   - Verify upstream BBS is running on port 8080

## Customization

### Adding New Components
1. Create new playbook file following naming convention
2. Add to `main.yaml` import list
3. Update `run_playbook.sh` component case statement
4. Document in this README

### Modifying Existing Components
- Each component is self-contained
- Variables are consistently defined across playbooks
- Handlers are defined per-playbook to avoid conflicts

## Contributing

When making changes:
1. Test individual components with `--component` flag
2. Verify full installation with `--full` flag
3. Update documentation for any new variables or features
4. Follow Ansible best practices for idempotency
