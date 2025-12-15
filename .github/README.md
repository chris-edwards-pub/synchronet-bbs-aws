# GitHub Actions Workflows - Cost Optimized

This repository includes a single, cost-optimized GitHub Actions workflow for automated container building and deployment.

## Workflow Overview

### `docker-build.yml` - Minimal Build Pipeline

**Triggers:**

- Push to `master`/`main` branch (when docker files change)
- Manual workflow dispatch

**Features:**

- Builds Docker image for `linux/amd64` platform
- Pushes to GitHub Container Registry (`ghcr.io`)
- Minimal resource usage - no PR builds, no caching, no security scans
- Simple tagging: `latest` and commit SHA

**Cost Optimizations:**

- **No PR builds**: Only builds on push to main branch
- **No BuildX setup**: Uses standard Docker build
- **No caching**: Reduces complexity and storage costs
- **No security scanning**: Eliminates expensive vulnerability scans
- **No multi-platform**: Single platform (linux/amd64) only
- **No metadata extraction**: Simple, fixed tagging strategy

## Container Registry

Images are published to:

```text
ghcr.io/chris-edwards-pub/synchronet-bbs:latest
ghcr.io/chris-edwards-pub/synchronet-bbs:<commit-sha>
```

## Usage Examples

### Pull and Run Latest

```bash
docker pull ghcr.io/chris-edwards-pub/synchronet-bbs:latest
docker run -d -p 2323:23 ghcr.io/chris-edwards-pub/synchronet-bbs:latest
```

### Use in Docker Compose

```yaml
services:
  synchronet:
    image: ghcr.io/chris-edwards-pub/synchronet-bbs:latest
    ports:
      - "2323:23"
    volumes:
      - synchronet-data:/home/sbbs/sbbs
```

## Platform Support

- **Primary**: `linux/amd64` (required for Synchronet)
- **Note**: ARM64 builds disabled due to Synchronet x86_64 requirement

## Secrets Required

The workflow uses only the built-in `GITHUB_TOKEN` for:

- Reading repository contents
- Writing to GitHub Container Registry

No additional secrets are required for basic functionality.
