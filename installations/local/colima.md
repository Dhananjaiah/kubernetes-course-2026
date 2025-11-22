# Colima - Container Runtime for macOS and Linux

Colima provides container runtimes on macOS (and Linux) with minimal setup. It's a lightweight alternative to Docker Desktop that supports both Docker and Kubernetes.

## 📋 Overview

- **Type**: Container runtime with Kubernetes support
- **Nodes**: Single-node K3s cluster
- **Resource Usage**: Low (2GB+ RAM)
- **Startup Time**: ~30 seconds
- **Best For**: macOS users, Docker Desktop alternative

## ✨ Features

- ✅ Free and open-source
- ✅ Minimal resource usage
- ✅ Docker and containerd support
- ✅ Kubernetes via K3s
- ✅ Multiple profiles
- ✅ Port forwarding
- ✅ Volume mounts
- ✅ x86_64 and ARM64 (M1/M2) support

## 📦 Prerequisites

- **macOS**: macOS 11.0 Big Sur or later
- **Linux**: Ubuntu, Fedora, Arch Linux
- **RAM**: 2GB minimum, 4GB recommended
- **Disk**: 10GB+ available

## 🚀 Installation

### macOS

```bash
# Install using Homebrew
brew install colima

# Install Docker CLI
brew install docker

# Install kubectl
brew install kubectl

# Verify installation
colima version
```

### Linux

```bash
# Install Colima
curl -LO https://github.com/abiosoft/colima/releases/latest/download/colima-Linux-x86_64
sudo install colima-Linux-x86_64 /usr/local/bin/colima

# Install Docker CLI
sudo apt install docker.io

# Install kubectl
sudo apt install kubectl

# Verify
colima version
```

## ⚙️ Quick Start

### Start Colima with Kubernetes

```bash
# Start with Kubernetes enabled
colima start --kubernetes

# Or with custom resources
colima start \
  --cpu 4 \
  --memory 8 \
  --disk 50 \
  --kubernetes

# Verify
kubectl cluster-info
kubectl get nodes
```

## 🔧 Configuration

### Resource Allocation

```bash
# Start with custom resources
colima start \
  --cpu 4 \
  --memory 8 \
  --disk 50 \
  --kubernetes
```

### Multiple Profiles

```bash
# Create different profiles
colima start dev --cpu 2 --memory 4
colima start prod --cpu 4 --memory 8 --kubernetes

# List profiles
colima list

# Switch profiles
colima stop dev
colima start prod
```

## 🐳 Working with Docker

```bash
# Start Colima
colima start

# Use Docker normally
docker build -t my-app:v1 .
docker run -d -p 8080:80 nginx
docker ps
docker images
```

## ☸️ Working with Kubernetes

```bash
# Deploy application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Use port-forward
kubectl port-forward svc/nginx 8080:80
curl http://localhost:8080
```

## 🔗 Additional Resources

- [GitHub Repository](https://github.com/abiosoft/colima)
- [Lima Documentation](https://github.com/lima-vm/lima)
- [K3s Documentation](https://docs.k3s.io/)

## ⚡ Quick Reference

```bash
# Basic Operations
colima start
colima start --kubernetes
colima stop
colima delete
colima status

# With Options
colima start --cpu 4 --memory 8 --kubernetes

# Docker
docker build -t <image> .
docker run <image>

# Kubernetes
kubectl get nodes
kubectl create deployment <name> --image=<image>
```

---

**Next Steps**: Colima provides an excellent lightweight alternative to Docker Desktop for macOS users.
