# Synchronet BBS Docker Container

This directory contains the Docker configuration for building and running Synchronet BBS in a containerized environment.

## Features

- **Base Image**: Amazon Linux 2 for AWS compatibility
- **Architecture**: x86_64 (amd64) - required for Synchronet BBS
- **JavaScript Engine**: SpiderMonkey 1.8.5 with full compilation from source
- **Crypto Support**: Cryptlib for secure communications
- **Port Mapping**: Host 2323 → Container 23 (telnet)

## Quick Start

### Build and Run Locally

```bash
# Build the container
docker compose build

# Start Synchronet BBS
docker compose up -d

# View logs
docker compose logs -f

# Connect via telnet
telnet localhost 2323
```

### Using Pre-built Images

```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/chris-edwards-pub/synchronet-bbs:latest

# Run with port mapping
docker run -d \
  --name synchronet-bbs \
  -p 2323:23 \
  -v synchronet-data:/home/sbbs/sbbs \
  ghcr.io/chris-edwards-pub/synchronet-bbs:latest
```

## Build Process

The container build process includes:

1. **Base Setup**: Amazon Linux 2 with development tools
2. **Dependencies**: autoconf-2.13, NSPR, build essentials
3. **Third-party Libraries**:
   - SpiderMonkey JavaScript engine (compiled from source)
   - Cryptlib for cryptographic operations
4. **Synchronet Compilation**: Full build from latest dailybuild_linux-x64 branch
5. **Installation**: Standard Synchronet installation with proper permissions

## Architecture Considerations

⚠️ **Important**: Synchronet BBS requires x86_64 architecture. The container is built with `--platform=linux/amd64` to ensure compatibility even on ARM64 hosts (like Apple Silicon Macs).

## Exposed Ports

- **23**: Telnet (mapped to host 2323)
- **80**: HTTP
- **443**: HTTPS
- **1123**: News (NNTP)
- **1883/1884**: MQTT
- **8080**: HTTP alternate
- **8883/8884**: MQTT over SSL

## Persistent Data

Put your `ctrl`, `data`, `exec` directories under `docker/data/sbbs` to persist configuration and runtime files.

## GitHub Actions

This repository includes a minimal cost-optimized workflow:

- **docker-build.yml**: Builds and pushes container images on changes (pushes only, no PR builds)

## Troubleshooting

### Build Issues

If you encounter build failures:

1. Ensure you're building for x86_64: `docker build --platform linux/amd64`
2. Check available disk space (build requires ~3GB)
3. Verify internet connectivity for downloading source packages

### Runtime Issues

For runtime problems:

1. Check container logs: `docker compose logs`
2. Verify port availability: `netstat -an | grep 2323`
3. Ensure proper volume permissions for persistent data

## Development

To modify the build:

1. Edit `Dockerfile` for build changes
2. Update `docker-compose.yaml` for runtime configuration
3. Test locally before pushing to trigger CI/CD

## Related Components

- **ansible/**: Automated deployment scripts for AWS EC2
- **terraform/**: Infrastructure as code for AWS resources
