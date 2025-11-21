# Minikube - Local Kubernetes Cluster

Minikube is the most popular tool for running Kubernetes locally. It creates a single-node or multi-node cluster on your local machine, supporting various hypervisors and container runtimes.

## 📋 Overview

- **Type**: Local development cluster
- **Nodes**: Single or multi-node
- **Resource Usage**: Medium (2GB+ RAM)
- **Startup Time**: ~2 minutes
- **Best For**: Beginners, feature testing, learning

## ✨ Features

- ✅ Multiple driver support (Docker, VirtualBox, Hyper-V, KVM, etc.)
- ✅ Kubernetes version management
- ✅ Addons ecosystem (dashboard, ingress, metrics-server)
- ✅ Multi-node clusters
- ✅ LoadBalancer support via `minikube tunnel`
- ✅ GPU support
- ✅ Container runtime selection (Docker, containerd, CRI-O)

## 📦 Prerequisites

- CPU: 2 cores or more
- RAM: 2GB minimum (4GB recommended)
- Disk: 20GB free space
- Container or VM driver:
  - Docker (recommended)
  - VirtualBox
  - Hyper-V (Windows)
  - KVM (Linux)

## 🚀 Installation

### Linux

```bash
# Download latest version
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

### macOS

```bash
# Using Homebrew
brew install minikube

# Or download manually
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

### Windows

```powershell
# Using Chocolatey
choco install minikube

# Or using Scoop
scoop install minikube

# Or download installer from:
# https://minikube.sigs.k8s.io/docs/start/

# Verify installation
minikube version
```

## ⚙️ Quick Start

### Basic Cluster

```bash
# Start minikube with Docker driver
minikube start

# Or specify driver explicitly
minikube start --driver=docker

# Check cluster status
minikube status

# Verify kubectl connection
kubectl get nodes
```

### Advanced Configuration

```bash
# Start with custom resources
minikube start \
  --cpus=4 \
  --memory=8192 \
  --disk-size=50g \
  --driver=docker

# Start with specific Kubernetes version
minikube start --kubernetes-version=v1.28.0

# Start multi-node cluster
minikube start --nodes=3

# Start with specific container runtime
minikube start --container-runtime=containerd
```

## 🔧 Configuration Options

### Resource Allocation

```bash
# Minimum setup (for learning)
minikube start --cpus=2 --memory=2048

# Recommended setup (for development)
minikube start --cpus=4 --memory=4096

# High-performance setup
minikube start --cpus=8 --memory=16384 --disk-size=100g
```

### Driver Selection

```bash
# Docker (recommended - works on all platforms)
minikube start --driver=docker

# VirtualBox (traditional VM)
minikube start --driver=virtualbox

# Hyper-V (Windows)
minikube start --driver=hyperv

# KVM2 (Linux)
minikube start --driver=kvm2

# Podman (Docker alternative)
minikube start --driver=podman
```

## 🎛️ Common Operations

### Cluster Management

```bash
# Stop cluster (preserves state)
minikube stop

# Delete cluster
minikube delete

# Pause cluster (saves resources)
minikube pause

# Resume paused cluster
minikube unpause

# Get cluster IP
minikube ip

# SSH into node
minikube ssh

# View cluster dashboard
minikube dashboard
```

### Addons

```bash
# List available addons
minikube addons list

# Enable ingress addon
minikube addons enable ingress

# Enable metrics-server
minikube addons enable metrics-server

# Enable dashboard
minikube addons enable dashboard

# Enable registry
minikube addons enable registry

# Disable addon
minikube addons disable <addon-name>
```

### Useful Addons

```bash
# Essential addons for development
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Storage addons
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

# Monitoring
minikube addons enable metrics-server

# Registry (for local images)
minikube addons enable registry
```

## 🔌 LoadBalancer Support

```bash
# In a separate terminal, run:
minikube tunnel

# This creates a network route to services of type LoadBalancer
# You may need to enter your password (requires sudo)

# Now LoadBalancer services will get external IPs
```

## 🐳 Working with Local Docker Images

### Option 1: Use Minikube's Docker Daemon

```bash
# Point your shell to minikube's docker daemon
eval $(minikube docker-env)

# Build image directly in minikube
docker build -t my-app:v1 .

# Use image in Kubernetes (set imagePullPolicy: Never)
kubectl run my-app --image=my-app:v1 --image-pull-policy=Never
```

### Option 2: Load Images from Host

```bash
# Build image on host
docker build -t my-app:v1 .

# Load into minikube
minikube image load my-app:v1

# Or use docker save/load
docker save my-app:v1 | minikube image load -
```

### Option 3: Use Minikube Registry

```bash
# Enable registry addon
minikube addons enable registry

# Get registry port
kubectl get svc -n kube-system

# Tag and push to registry
docker tag my-app:v1 localhost:5000/my-app:v1
docker push localhost:5000/my-app:v1
```

## 🔍 Multi-Node Clusters

```bash
# Create 3-node cluster
minikube start --nodes=3

# View nodes
kubectl get nodes

# Add more nodes to existing cluster
minikube node add

# Delete a node
minikube node delete <node-name>

# List nodes
minikube node list
```

## 🐛 Troubleshooting

### Common Issues

**Cluster won't start**
```bash
# Check system resources
minikube start --alsologtostderr -v=7

# Delete and recreate
minikube delete
minikube start
```

**Docker driver issues**
```bash
# Ensure Docker is running
docker ps

# Check Docker version (must be recent)
docker version

# Try with sudo (Linux)
sudo minikube start --driver=docker --force
```

**Not enough resources**
```bash
# Start with minimal resources
minikube start --cpus=2 --memory=2048

# Or increase Docker Desktop resources (Mac/Windows)
```

**Connection issues**
```bash
# Reset kubectl context
minikube update-context

# Or manually set context
kubectl config use-context minikube

# Verify connection
kubectl cluster-info
```

**Image pull errors**
```bash
# Use minikube's Docker daemon
eval $(minikube docker-env)

# Or check image pull policy
kubectl describe pod <pod-name>
```

### Performance Issues

```bash
# Check resource usage
minikube status
minikube ssh
top

# Increase resources
minikube delete
minikube start --cpus=4 --memory=8192

# Cleanup unused resources
minikube ssh
docker system prune -a
```

## 📊 Monitoring and Logging

```bash
# View logs
minikube logs

# Follow logs
minikube logs -f

# View specific component logs
minikube logs --file=kube-apiserver

# Enable metrics
minikube addons enable metrics-server

# View resource usage
kubectl top nodes
kubectl top pods -A
```

## 🔄 Kubernetes Version Management

```bash
# List available versions
minikube config defaults kubernetes-version

# Start with specific version
minikube start --kubernetes-version=v1.28.0

# Upgrade cluster
minikube delete
minikube start --kubernetes-version=v1.29.0
```

## 🎓 Best Practices

1. **Start with recommended resources**: 2 CPUs, 4GB RAM minimum
2. **Use Docker driver**: Best compatibility and performance
3. **Enable essential addons**: ingress, metrics-server
4. **Use minikube tunnel**: For LoadBalancer services
5. **Cleanup regularly**: `minikube delete` when not in use
6. **Version management**: Test against target K8s version
7. **Use local images**: Faster development with local Docker daemon

## 📚 Examples

### Complete Development Setup

```bash
# Start cluster with good defaults
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Enable essential addons
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Setup local image development
eval $(minikube docker-env)

# Open dashboard
minikube dashboard
```

### Deploy Sample Application

```bash
# Create deployment
kubectl create deployment nginx --image=nginx

# Expose as LoadBalancer
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# In another terminal, enable LoadBalancer
minikube tunnel

# Get service URL
minikube service nginx --url

# Or open in browser
minikube service nginx
```

## 🔗 Additional Resources

- [Official Documentation](https://minikube.sigs.k8s.io/docs/)
- [GitHub Repository](https://github.com/kubernetes/minikube)
- [Addons Guide](https://minikube.sigs.k8s.io/docs/handbook/addons/)
- [Drivers Documentation](https://minikube.sigs.k8s.io/docs/drivers/)

## ⚡ Quick Reference

```bash
# Start/Stop
minikube start
minikube stop
minikube delete

# Cluster Info
minikube status
minikube ip
minikube version

# Access
minikube dashboard
minikube ssh
minikube service <service-name>

# Addons
minikube addons list
minikube addons enable <addon>

# Images
eval $(minikube docker-env)
minikube image load <image>

# Multi-node
minikube start --nodes=3
minikube node add

# Troubleshooting
minikube logs
minikube delete && minikube start
```

---

**Next Steps**: After setting up Minikube, proceed to [Module 1: Docker & Containers](../../docs/01-docker-containers.md) to start learning Kubernetes.
