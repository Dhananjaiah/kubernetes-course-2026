# MicroK8s - Canonical's Minimal Kubernetes

MicroK8s is a lightweight, pure-upstream Kubernetes distribution from Canonical, optimized for easy installation and management on workstations and edge devices.

## 📋 Overview

- **Type**: Lightweight Kubernetes distribution
- **Nodes**: Single or multi-node
- **Resource Usage**: Low (540MB RAM minimum)
- **Startup Time**: ~1 minute
- **Best For**: Ubuntu users, quick setup, development

## ✨ Features

- ✅ Zero-ops, minimal production Kubernetes
- ✅ Single command install and setup
- ✅ Automatic updates
- ✅ Addon ecosystem (DNS, Dashboard, Ingress, etc.)
- ✅ Strict confinement and security
- ✅ Multi-node clustering
- ✅ Works on Windows, macOS, Linux
- ✅ GPU support
- ✅ High availability

## 📦 Prerequisites

- 4GB RAM minimum (540MB+ for K8s itself)
- 20GB disk space
- Ubuntu 18.04+ / Other Linux / Windows / macOS
- snapd installed

## 🚀 Installation

### Linux (Ubuntu/Debian)

```bash
# Install snapd (if not already installed)
sudo apt update
sudo apt install snapd -y

# Install MicroK8s
sudo snap install microk8s --classic

# Add user to microk8s group
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Reload group membership
newgrp microk8s

# Verify installation
microk8s status --wait-ready
```

### Linux (Other Distributions)

```bash
# Install snapd for your distribution:
# Fedora/RHEL/CentOS:
sudo dnf install snapd
sudo ln -s /var/lib/snapd/snap /snap

# Arch Linux:
sudo pacman -S snapd
sudo systemctl enable --now snapd.socket

# Then install MicroK8s
sudo snap install microk8s --classic
```

### macOS

```bash
# Install with Homebrew
brew install ubuntu/microk8s/microk8s

# Initialize MicroK8s
microk8s install

# Check status
microk8s status
```

### Windows

```powershell
# Using Windows Package Manager (winget)
winget install Canonical.MicroK8s

# Or download installer from:
# https://microk8s.io/docs/install-windows

# After installation
microk8s status
```

## ⚙️ Quick Start

### Basic Setup

```bash
# Check status
microk8s status --wait-ready

# Enable DNS addon (essential)
microk8s enable dns

# Enable dashboard
microk8s enable dashboard

# Access kubectl
microk8s kubectl get nodes

# Create alias for convenience
echo 'alias kubectl="microk8s kubectl"' >> ~/.bashrc
source ~/.bashrc

# Or export kubeconfig
microk8s config > ~/.kube/config
```

### Essential Addons

```bash
# List available addons
microk8s status

# Enable DNS (required for service discovery)
microk8s enable dns

# Enable Dashboard
microk8s enable dashboard

# Enable Storage
microk8s enable storage

# Enable Ingress
microk8s enable ingress

# Enable Registry
microk8s enable registry

# Enable Metrics Server
microk8s enable metrics-server
```

## 🔧 Configuration and Addons

### Popular Addons

```bash
# Networking
microk8s enable dns               # CoreDNS
microk8s enable ingress           # NGINX Ingress Controller
microk8s enable metallb:10.0.0.1-10.0.0.10  # Load Balancer

# Storage
microk8s enable storage           # Hostpath storage
microk8s enable hostpath-storage  # Alternative storage

# Monitoring
microk8s enable dashboard         # Kubernetes Dashboard
microk8s enable metrics-server    # Resource metrics
microk8s enable prometheus        # Prometheus monitoring

# Service Mesh
microk8s enable istio             # Istio service mesh
microk8s enable linkerd           # Linkerd service mesh

# CI/CD
microk8s enable registry          # Private container registry
microk8s enable helm3             # Helm package manager

# Databases
microk8s enable postgres          # PostgreSQL operator

# GPU
microk8s enable gpu               # NVIDIA GPU support

# Security
microk8s enable cert-manager      # Certificate management
microk8s enable rbac              # Role-based access control
```

### Addon Management

```bash
# List all available addons
microk8s status

# Enable addon
microk8s enable <addon-name>

# Disable addon
microk8s disable <addon-name>

# Enable multiple addons
microk8s enable dns dashboard storage ingress
```

## 🌐 Networking

### MetalLB (Load Balancer)

```bash
# Enable MetalLB with IP range
microk8s enable metallb:192.168.1.240-192.168.1.250

# Create LoadBalancer service
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get external IP
kubectl get svc nginx
```

### Ingress Controller

```bash
# Enable ingress
microk8s enable ingress

# Create ingress resource
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

# Add to /etc/hosts
echo "127.0.0.1 nginx.local" | sudo tee -a /etc/hosts

# Access
curl http://nginx.local
```

## 🐳 Working with Images

### Built-in Registry

```bash
# Enable registry addon
microk8s enable registry

# Registry is available at localhost:32000

# Build and push image
docker build -t localhost:32000/my-app:v1 .
docker push localhost:32000/my-app:v1

# Use in deployment
kubectl create deployment my-app --image=localhost:32000/my-app:v1
```

### Import Images

```bash
# Import from Docker
docker save my-app:v1 > my-app.tar
microk8s ctr image import my-app.tar

# Or directly from Docker daemon
docker pull nginx:alpine
microk8s ctr images pull docker.io/library/nginx:alpine
```

## 🏢 Multi-Node Clustering

### Add Nodes to Cluster

**On the main node:**
```bash
# Generate join token
microk8s add-node

# Output will show join command, like:
# microk8s join 192.168.1.100:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05
```

**On the new node:**
```bash
# Install MicroK8s
sudo snap install microk8s --classic

# Join the cluster (use the command from add-node)
microk8s join 192.168.1.100:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05

# Verify from main node
microk8s kubectl get nodes
```

### High Availability (3+ nodes)

```bash
# Create HA cluster with 3 control plane nodes
# On Node 1:
microk8s add-node

# On Node 2 (join as control plane):
microk8s join <connection-string> --worker=false

# On Node 3 (join as control plane):
microk8s add-node  # from Node 1 or 2
microk8s join <connection-string> --worker=false

# Add worker nodes
microk8s add-node
microk8s join <connection-string>  # from worker node
```

## 📊 Management and Operations

### Cluster Management

```bash
# Start MicroK8s
microk8s start

# Stop MicroK8s
microk8s stop

# Check status
microk8s status

# Check detailed status
microk8s inspect

# View logs
microk8s kubectl logs -n kube-system <pod-name>
```

### Access Dashboard

```bash
# Enable dashboard
microk8s enable dashboard

# Get access token
microk8s kubectl create token default

# Or get token from secret
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token

# Port forward dashboard
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443

# Access: https://localhost:10443
```

### Resource Monitoring

```bash
# Enable metrics-server
microk8s enable metrics-server

# View resource usage
microk8s kubectl top nodes
microk8s kubectl top pods -A

# Enable Prometheus monitoring
microk8s enable prometheus
```

## 🐛 Troubleshooting

### Service Not Starting

```bash
# Check status
microk8s status

# Inspect cluster
microk8s inspect

# Reset MicroK8s
microk8s reset

# Reinstall if needed
sudo snap remove microk8s
sudo snap install microk8s --classic
```

### Permission Issues

```bash
# Add user to microk8s group
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Re-login or use newgrp
newgrp microk8s

# Verify permissions
microk8s status
```

### Networking Issues

```bash
# Check DNS
microk8s enable dns
microk8s kubectl run test --image=busybox --rm -it -- nslookup kubernetes.default

# Reset network
microk8s stop
sudo iptables -F
sudo iptables -t nat -F
microk8s start

# Check firewall
sudo ufw allow in on cni0
sudo ufw allow out on cni0
```

### Addon Issues

```bash
# Disable and re-enable addon
microk8s disable <addon>
microk8s enable <addon>

# Check addon status
microk8s status

# View addon logs
microk8s kubectl logs -n kube-system -l app=<addon-name>
```

## 🔄 Updates and Upgrades

### Automatic Updates

```bash
# MicroK8s automatically updates via snap
# Check for updates
sudo snap refresh --list

# Manually refresh
sudo snap refresh microk8s

# Disable auto-refresh
sudo snap refresh --hold microk8s

# Re-enable auto-refresh
sudo snap refresh --unhold microk8s
```

### Channel Management

```bash
# Switch to different channel
sudo snap refresh microk8s --channel=1.28/stable

# Available channels
sudo snap info microk8s

# Example channels:
# 1.28/stable  - Kubernetes 1.28
# 1.27/stable  - Kubernetes 1.27
# latest/edge  - Development builds
```

## 🗑️ Uninstallation

```bash
# Stop MicroK8s
microk8s stop

# Remove snap
sudo snap remove microk8s

# Remove configuration (optional)
sudo rm -rf ~/.kube

# Remove group membership
sudo gpasswd -d $USER microk8s
```

## 🎓 Best Practices

1. **Enable essential addons**: dns, dashboard, storage
2. **Use MetalLB**: For LoadBalancer services
3. **Regular updates**: Keep MicroK8s updated
4. **Multi-node for prod**: Use 3+ nodes for HA
5. **Monitor resources**: Enable metrics-server
6. **Backup configs**: Export important manifests
7. **Security**: Use RBAC and network policies

## 📚 Examples

### Complete Development Setup

```bash
# Install MicroK8s
sudo snap install microk8s --classic

# Setup user access
sudo usermod -a -G microk8s $USER
newgrp microk8s

# Enable essential addons
microk8s enable dns dashboard storage ingress registry metrics-server

# Setup kubectl alias
echo 'alias kubectl="microk8s kubectl"' >> ~/.bashrc
source ~/.bashrc

# Verify setup
kubectl get all -A

# Deploy test application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Access dashboard
microk8s dashboard-proxy
```

### Production-Ready Cluster

```bash
# Install on all nodes
sudo snap install microk8s --classic --channel=1.28/stable

# On Node 1 (Main):
microk8s enable dns storage ingress metrics-server metallb:10.0.0.100-10.0.0.110
microk8s add-node  # Get join command

# On Node 2 & 3 (Control Plane):
microk8s join <connection-string> --worker=false

# On Worker Nodes:
microk8s add-node  # from any control plane
microk8s join <connection-string>

# Verify cluster
microk8s kubectl get nodes
microk8s kubectl get pods -A

# Enable HA addons
microk8s enable prometheus
microk8s enable cert-manager
```

## 🔗 Additional Resources

- [Official Documentation](https://microk8s.io/docs)
- [GitHub Repository](https://github.com/canonical/microk8s)
- [Addon Documentation](https://microk8s.io/docs/addons)
- [Community Forum](https://discuss.kubernetes.io/)

## ⚡ Quick Reference

```bash
# Installation
sudo snap install microk8s --classic

# Cluster Operations
microk8s status
microk8s start
microk8s stop
microk8s reset

# Addons
microk8s status
microk8s enable <addon>
microk8s disable <addon>

# kubectl Access
microk8s kubectl <command>
alias kubectl="microk8s kubectl"
microk8s config > ~/.kube/config

# Multi-node
microk8s add-node
microk8s join <connection-string>

# Troubleshooting
microk8s inspect
microk8s reset

# Dashboard
microk8s dashboard-proxy

# Updates
sudo snap refresh microk8s
```

---

**Next Steps**: After setting up MicroK8s, explore the addon ecosystem and deploy applications with the built-in registry.
