# Rancher Desktop - Container Management and Kubernetes

Rancher Desktop is an open-source desktop application for Mac, Windows, and Linux that provides Kubernetes and container management. It's a great alternative to Docker Desktop.

## 📋 Overview

- **Type**: Desktop Kubernetes
- **Nodes**: Single-node
- **Resource Usage**: Medium (2GB+ RAM)
- **Startup Time**: ~1-2 minutes
- **Best For**: Docker Desktop alternative, K3s-based development

## ✨ Features

- ✅ Free and open-source
- ✅ Runs K3s or RKE2 Kubernetes
- ✅ Container runtime choice (containerd or dockerd)
- ✅ Built-in kubectl, helm, nerdctl
- ✅ Docker CLI compatibility
- ✅ Kubernetes version selection
- ✅ Port forwarding
- ✅ Image building with nerdctl or docker
- ✅ No licensing restrictions

## 📦 Prerequisites

- **Windows**: Windows 10/11 (64-bit), 4GB RAM
- **macOS**: macOS 10.15 or later, 4GB RAM  
- **Linux**: Ubuntu, Fedora, or other distros, 4GB RAM
- **Disk**: 10GB+ available space

## 🚀 Installation

### macOS

```bash
# Using Homebrew
brew install --cask rancher-desktop

# Or download from website:
# https://rancherdesktop.io/

# Launch application
open -a "Rancher Desktop"

# Verify installation
rdctl version
kubectl version --client
```

### Windows

```powershell
# Using Chocolatey
choco install rancher-desktop

# Or using Scoop
scoop bucket add extras
scoop install rancher-desktop

# Or download installer from:
# https://github.com/rancher-sandbox/rancher-desktop/releases

# Verify installation
rdctl version
kubectl version --client
```

### Linux

```bash
# Download the latest release
# https://github.com/rancher-sandbox/rancher-desktop/releases

# For Debian/Ubuntu (.deb)
wget https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.11.0/rancher-desktop-1.11.0-amd64.deb
sudo apt install ./rancher-desktop-1.11.0-amd64.deb

# For Fedora/RHEL (.rpm)
wget https://github.com/rancher-sandbox/rancher-desktop/releases/download/v1.11.0/rancher-desktop-1.11.0.x86_64.rpm
sudo dnf install ./rancher-desktop-1.11.0.x86_64.rpm

# Verify installation
rdctl version
```

## ⚙️ Configuration

### Initial Setup

1. Launch Rancher Desktop
2. Accept License Agreement
3. Choose Kubernetes Version (e.g., v1.28.4)
4. Select Container Runtime:
   - **containerd** (recommended, lightweight)
   - **dockerd** (Docker compatibility)
5. Configure Resources (CPU, Memory)
6. Wait for Kubernetes to start

### Using nerdctl (containerd)

```bash
# Build images
nerdctl build -t my-app:v1 .

# Run containers
nerdctl run -d -p 8080:80 nginx

# List containers/images
nerdctl ps
nerdctl images
```

### Using Docker (dockerd)

```bash
# Enable dockerd in settings
# Use docker commands normally
docker build -t my-app:v1 .
docker run -d -p 8080:80 nginx
docker ps
docker images
```

## 🔌 Networking

### LoadBalancer Services

```bash
# Create LoadBalancer service
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Access service
curl http://localhost
```

## 🔗 Additional Resources

- [Official Documentation](https://docs.rancherdesktop.io/)
- [GitHub Repository](https://github.com/rancher-sandbox/rancher-desktop)
- [nerdctl Documentation](https://github.com/containerd/nerdctl)

## ⚡ Quick Reference

```bash
# Rancher Desktop CLI
rdctl version
rdctl list-settings
rdctl set --memory 8 --cpus 4

# Container Management (nerdctl)
nerdctl build -t <image> .
nerdctl images
nerdctl ps
nerdctl run <image>

# Or with Docker
docker build -t <image> .
docker images
docker ps
docker run <image>

# Kubernetes
kubectl get nodes
kubectl create deployment <name> --image=<image>
```

---

**Next Steps**: Rancher Desktop provides an excellent open-source alternative to Docker Desktop with powerful Kubernetes capabilities.
