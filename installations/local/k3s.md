# K3s - Lightweight Kubernetes

K3s is a lightweight, certified Kubernetes distribution designed for IoT, edge computing, and resource-constrained environments. It's a single binary less than 100MB in size.

## 📋 Overview

- **Type**: Lightweight Kubernetes distribution
- **Nodes**: Single or multi-node
- **Resource Usage**: Very Low (512MB RAM minimum)
- **Startup Time**: ~30 seconds
- **Best For**: Edge computing, IoT, low-resource environments

## ✨ Features

- ✅ Single binary less than 100MB
- ✅ Minimal resource requirements (512MB RAM)
- ✅ Fast installation and startup
- ✅ Full Kubernetes API compliance
- ✅ Built-in SQLite database (etcd replacement)
- ✅ Automatic SSL certificate management
- ✅ Embedded load balancer (ServiceLB)
- ✅ Embedded ingress controller (Traefik)
- ✅ Local storage provisioner
- ✅ Helm controller built-in

## 📦 Prerequisites

- Linux system (Ubuntu, Debian, RHEL, CentOS, SLES)
- 512MB+ RAM
- 200MB+ disk space
- Modern Linux kernel (3.10+)
- systemd or OpenRC

## 🚀 Installation

### Quick Install (Recommended)

```bash
# Install latest stable version
curl -sfL https://get.k3s.io | sh -

# Check installation
sudo k3s kubectl get nodes

# Check if k3s is running
sudo systemctl status k3s
```

### Install Specific Version

```bash
# Install specific version
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.4+k3s1 sh -

# List available versions
curl -s https://api.github.com/repos/k3s-io/k3s/releases | grep tag_name
```

### Server Installation (Control Plane)

```bash
# Install as server
curl -sfL https://get.k3s.io | sh -s - server

# Install with options
curl -sfL https://get.k3s.io | sh -s - server \
  --write-kubeconfig-mode 644 \
  --disable traefik \
  --disable servicelb
```

### Agent Installation (Worker Node)

```bash
# Get server token from control plane
sudo cat /var/lib/rancher/k3s/server/node-token

# Install agent on worker node
curl -sfL https://get.k3s.io | K3S_URL=https://server-ip:6443 \
  K3S_TOKEN=<token> sh -
```

## ⚙️ Configuration

### Installation Options

```bash
# Install without traefik (use your own ingress)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -

# Install without servicelb (use MetalLB)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable servicelb" sh -

# Install with custom data directory
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--data-dir /opt/k3s" sh -

# Install with Docker instead of containerd
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -
```

### Configuration File

Create `/etc/rancher/k3s/config.yaml`:

```yaml
write-kubeconfig-mode: "0644"
tls-san:
  - "k3s.example.com"
  - "192.168.1.100"
disable:
  - traefik
  - servicelb
node-name: "my-k3s-node"
cluster-init: true
```

Then install:

```bash
curl -sfL https://get.k3s.io | sh -
```

### Kubeconfig Setup

```bash
# Copy kubeconfig
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Or export directly
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Or use k3s kubectl
sudo k3s kubectl get nodes

# Create alias
echo 'alias kubectl="sudo k3s kubectl"' >> ~/.bashrc
```

## 🏢 High Availability Setup

### Embedded etcd (Simple HA)

**Server 1 (Initialize cluster):**
```bash
curl -sfL https://get.k3s.io | sh -s - server \
  --cluster-init \
  --tls-san 192.168.1.100
```

**Server 2 & 3 (Join cluster):**
```bash
# Get token from first server
sudo cat /var/lib/rancher/k3s/server/node-token

# Join cluster
curl -sfL https://get.k3s.io | sh -s - server \
  --server https://192.168.1.100:6443 \
  --token <node-token>
```

### External Database (MySQL/PostgreSQL)

**Using MySQL:**
```bash
# Install on first server
curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="mysql://user:pass@tcp(hostname:3306)/k3s"

# Join additional servers
curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="mysql://user:pass@tcp(hostname:3306)/k3s"
```

**Using PostgreSQL:**
```bash
curl -sfL https://get.k3s.io | sh -s - server \
  --datastore-endpoint="postgres://user:pass@hostname:5432/k3s?sslmode=disable"
```

## 🔌 Built-in Components

### ServiceLB (Load Balancer)

```bash
# ServiceLB is enabled by default
# Create LoadBalancer service
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Service gets external IP from node
kubectl get svc nginx
```

### Traefik Ingress

```bash
# Traefik is enabled by default
# Create ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
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

# Access via host header
curl -H "Host: nginx.local" http://localhost
```

### Local Path Provisioner

```bash
# Automatically enabled for dynamic PVs
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
EOF

# PV is automatically created
kubectl get pv
```

### Helm Controller

```bash
# Deploy Helm charts via HelmChart CRD
cat <<EOF | kubectl apply -f -
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: traefik
  namespace: kube-system
spec:
  chart: traefik
  repo: https://helm.traefik.io/traefik
  targetNamespace: kube-system
  valuesContent: |-
    rbac:
      enabled: true
EOF
```

## 🐳 Container Runtime

### Using containerd (Default)

```bash
# containerd is default
curl -sfL https://get.k3s.io | sh -

# Import images
sudo k3s ctr images import my-image.tar

# List images
sudo k3s ctr images list
```

### Using Docker

```bash
# Install Docker first
curl -fsSL https://get.docker.com | sh

# Install K3s with Docker
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -

# Use docker commands
docker images
docker pull nginx
```

## 🎯 Common Use Cases

### Edge Computing

```bash
# Install K3s on edge device
curl -sfL https://get.k3s.io | sh -s - agent \
  --server https://central-server:6443 \
  --token <token> \
  --node-label location=edge \
  --node-label device=sensor
```

### IoT Gateway

```bash
# Lightweight installation
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
  --disable traefik \
  --disable servicelb \
  --disable metrics-server \
  --write-kubeconfig-mode 644" sh -
```

### Development Environment

```bash
# Single-node development cluster
curl -sfL https://get.k3s.io | sh -

# Install K9s for management
curl -sS https://webinstall.dev/k9s | bash

# Start developing
kubectl create deployment myapp --image=myapp:latest
```

## 🐛 Troubleshooting

### Service Not Starting

```bash
# Check service status
sudo systemctl status k3s

# View logs
sudo journalctl -u k3s -f

# Check for errors
sudo k3s check-config

# Restart service
sudo systemctl restart k3s
```

### Networking Issues

```bash
# Check CNI
sudo ls /var/lib/rancher/k3s/agent/etc/cni/net.d/

# Check iptables
sudo iptables -L -n -v

# Reset iptables
sudo systemctl stop k3s
sudo iptables -F
sudo iptables -t nat -F
sudo systemctl start k3s
```

### Storage Issues

```bash
# Check local-path-provisioner
kubectl get pods -n kube-system | grep local-path

# Check PV/PVC
kubectl get pv
kubectl get pvc

# View provisioner logs
kubectl logs -n kube-system -l app=local-path-provisioner
```

### Node Not Ready

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check kubelet
sudo systemctl status k3s-agent  # on agent nodes
sudo systemctl status k3s         # on server nodes

# View kubelet logs
sudo journalctl -u k3s-agent -f
```

## 📊 Management and Operations

### Cluster Management

```bash
# View cluster info
kubectl cluster-info
kubectl get nodes

# View all resources
kubectl get all -A

# Check cluster components
kubectl get pods -n kube-system
```

### Service Management

```bash
# Check service status
sudo systemctl status k3s

# Start/Stop/Restart
sudo systemctl start k3s
sudo systemctl stop k3s
sudo systemctl restart k3s

# Enable/Disable autostart
sudo systemctl enable k3s
sudo systemctl disable k3s

# View logs
sudo journalctl -u k3s -f
```

### Upgrade K3s

```bash
# Using install script (upgrades to latest)
curl -sfL https://get.k3s.io | sh -

# Or specific version
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.4+k3s1 sh -

# Verify version
k3s --version
kubectl version
```

### Backup and Restore

```bash
# Backup (with embedded etcd)
sudo k3s etcd-snapshot save --name my-snapshot

# List snapshots
sudo k3s etcd-snapshot ls

# Restore from snapshot
sudo systemctl stop k3s
sudo k3s server --cluster-reset --cluster-reset-restore-path=/var/lib/rancher/k3s/server/db/snapshots/my-snapshot
sudo systemctl start k3s
```

## 🗑️ Uninstallation

```bash
# Uninstall server
sudo /usr/local/bin/k3s-uninstall.sh

# Uninstall agent
sudo /usr/local/bin/k3s-agent-uninstall.sh

# Remove all data
sudo rm -rf /var/lib/rancher/k3s
sudo rm -rf /etc/rancher/k3s
```

## 🎓 Best Practices

1. **Resource limits**: Perfect for 512MB+ RAM devices
2. **HA setup**: Use 3 or 5 servers for production
3. **Backup regularly**: Use etcd snapshots
4. **Security**: Run as non-root user where possible
5. **Monitoring**: Install lightweight monitoring
6. **Updates**: Keep K3s updated regularly
7. **Configuration**: Use config files for consistency

## 📚 Examples

### Complete Single-Node Setup

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -s - server \
  --write-kubeconfig-mode 644 \
  --disable traefik

# Setup kubectl access
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config

# Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml

# Deploy test application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Verify
kubectl get all
```

### Multi-Node Cluster

```bash
# On Server Node:
curl -sfL https://get.k3s.io | sh -s - server \
  --write-kubeconfig-mode 644 \
  --cluster-init

# Get token
sudo cat /var/lib/rancher/k3s/server/node-token

# On Worker Nodes:
curl -sfL https://get.k3s.io | K3S_URL=https://server-ip:6443 \
  K3S_TOKEN=<token> sh -s - agent

# Verify from server
kubectl get nodes
```

## 🔗 Additional Resources

- [Official Documentation](https://docs.k3s.io/)
- [GitHub Repository](https://github.com/k3s-io/k3s)
- [K3s Architecture](https://docs.k3s.io/architecture)
- [Installation Options](https://docs.k3s.io/installation/configuration)

## ⚡ Quick Reference

```bash
# Installation
curl -sfL https://get.k3s.io | sh -

# Service Management
sudo systemctl {start|stop|restart|status} k3s
sudo journalctl -u k3s -f

# kubectl Access
sudo k3s kubectl get nodes
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Cluster Operations
sudo k3s etcd-snapshot save
sudo k3s etcd-snapshot ls

# Uninstall
sudo /usr/local/bin/k3s-uninstall.sh
```

---

**Next Steps**: K3s is perfect for edge computing and IoT. Consider exploring Rancher for managing multiple K3s clusters.
