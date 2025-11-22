# k3d - K3s in Docker

k3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in Docker. It makes creating multi-node k3s clusters extremely fast and easy.

## 📋 Overview

- **Type**: Local development cluster
- **Nodes**: Multi-node support
- **Resource Usage**: Very Low (512MB+ RAM)
- **Startup Time**: ~20 seconds
- **Best For**: Fast setup, CI/CD, development

## ✨ Features

- ✅ Blazing fast cluster creation (~20 seconds)
- ✅ Runs K3s in Docker containers
- ✅ Multi-cluster and multi-node support
- ✅ Built-in load balancer
- ✅ Automatic port mapping
- ✅ Local registry integration
- ✅ Very lightweight (uses K3s)
- ✅ Excellent for CI/CD pipelines

## 📦 Prerequisites

- Docker installed and running
- kubectl installed
- 512MB+ RAM available per node
- Docker API version 1.13+

## 🚀 Installation

### Linux

```bash
# Using install script
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Or download specific version
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.6.0 bash

# Or download binary manually
wget https://github.com/k3d-io/k3d/releases/download/v5.6.0/k3d-linux-amd64
chmod +x k3d-linux-amd64
sudo mv k3d-linux-amd64 /usr/local/bin/k3d

# Verify installation
k3d version
```

### macOS

```bash
# Using Homebrew
brew install k3d

# Or using install script
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Verify installation
k3d version
```

### Windows

```powershell
# Using Chocolatey
choco install k3d

# Or using Scoop
scoop install k3d

# Or download from:
# https://github.com/k3d-io/k3d/releases

# Verify installation
k3d version
```

## ⚙️ Quick Start

### Create Basic Cluster

```bash
# Create single-node cluster
k3d cluster create

# Create cluster with custom name
k3d cluster create mycluster

# Create cluster with multiple workers
k3d cluster create mycluster --agents 3

# Create cluster with multiple servers (HA)
k3d cluster create mycluster --servers 3 --agents 3

# List clusters
k3d cluster list

# Delete cluster
k3d cluster delete mycluster
```

### Verify Installation

```bash
# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get pods
kubectl get pods -A
```

## 🔧 Advanced Configuration

### Multi-Node Cluster

```bash
# Create cluster with 3 servers and 3 agents
k3d cluster create multinode \
  --servers 3 \
  --agents 3

# Create with custom ports
k3d cluster create mycluster \
  --api-port 6550 \
  --servers 1 \
  --agents 2
```

### Port Mapping

```bash
# Map ports for accessing services
k3d cluster create mycluster \
  --port 8080:80@loadbalancer \
  --port 8443:443@loadbalancer

# Map multiple ports
k3d cluster create mycluster \
  -p "8080:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  -p "5432:5432@agent:0"
```

### Volume Mounts

```bash
# Mount host directory into cluster nodes
k3d cluster create mycluster \
  --volume /my/host/path:/path/in/node@all

# Mount to specific node
k3d cluster create mycluster \
  --volume /my/path:/node/path@server:0

# Multiple volumes
k3d cluster create mycluster \
  -v /path1:/node1@all \
  -v /path2:/node2@server:0
```

### Configuration File

Create `k3d-config.yaml`:

```yaml
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: mycluster
servers: 1
agents: 3
image: rancher/k3s:v1.28.4-k3s1
ports:
  - port: 8080:80
    nodeFilters:
      - loadbalancer
  - port: 8443:443
    nodeFilters:
      - loadbalancer
options:
  k3d:
    wait: true
    timeout: "60s"
  k3s:
    extraArgs:
      - arg: --disable=traefik
        nodeFilters:
          - server:*
  kubeconfig:
    updateDefaultKubeconfig: true
    switchCurrentContext: true
registries:
  create:
    name: registry.localhost
    host: "0.0.0.0"
    hostPort: "5000"
```

Create cluster from config:

```bash
k3d cluster create --config k3d-config.yaml
```

## 🐳 Working with Images

### Load Images

```bash
# Build your image
docker build -t my-app:v1 .

# Load into k3d cluster
k3d image import my-app:v1 -c mycluster

# Load multiple images
k3d image import image1:v1 image2:v1 -c mycluster

# Load from tar archive
k3d image import my-image.tar -c mycluster
```

### Local Registry

```bash
# Create cluster with registry
k3d cluster create mycluster --registry-create registry:0.0.0.0:5000

# Or create registry separately
k3d registry create myregistry.localhost --port 5000

# Create cluster connected to registry
k3d cluster create mycluster --registry-use k3d-myregistry.localhost:5000

# Tag and push to local registry
docker tag my-app:v1 k3d-myregistry.localhost:5000/my-app:v1
docker push k3d-myregistry.localhost:5000/my-app:v1

# Use in Kubernetes
kubectl create deployment my-app --image=k3d-myregistry.localhost:5000/my-app:v1
```

## 🔌 LoadBalancer Support

k3d includes built-in LoadBalancer support via Serverlb:

```bash
# Create cluster (LoadBalancer automatically enabled)
k3d cluster create mycluster --port 8080:80@loadbalancer

# Create LoadBalancer service
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Access via localhost:8080
curl localhost:8080
```

## 🌐 Ingress Setup

### Using Traefik (Default)

```bash
# Create cluster (Traefik is enabled by default)
k3d cluster create mycluster -p "8080:80@loadbalancer"

# Deploy application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80

# Create Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

# Access via localhost:8080
curl localhost:8080
```

### Using NGINX Ingress

```bash
# Create cluster without Traefik
k3d cluster create mycluster \
  --port 8080:80@loadbalancer \
  --port 8443:443@loadbalancer \
  --k3s-arg "--disable=traefik@server:*"

# Install NGINX Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Wait for ingress controller
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

## 🎯 Common Use Cases

### CI/CD Integration

```yaml
# GitLab CI example
test:
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  script:
    - k3d cluster create test
    - kubectl apply -f manifests/
    - kubectl wait --for=condition=ready pod -l app=myapp
    - k3d cluster delete test
```

### Development Workflow

```bash
# Create development cluster
k3d cluster create dev \
  --agents 2 \
  -p "8080:80@loadbalancer" \
  -p "8443:443@loadbalancer" \
  --registry-create dev-registry:0.0.0.0:5000

# Build and deploy
docker build -t dev-registry:5000/my-app:latest .
docker push dev-registry:5000/my-app:latest
kubectl create deployment my-app --image=dev-registry:5000/my-app:latest

# Make changes and rebuild
docker build -t dev-registry:5000/my-app:latest .
docker push dev-registry:5000/my-app:latest
kubectl rollout restart deployment my-app
```

### Testing Different K8s Versions

```bash
# Create cluster with specific K3s version
k3d cluster create k3s-v1-28 --image rancher/k3s:v1.28.4-k3s1
k3d cluster create k3s-v1-27 --image rancher/k3s:v1.27.8-k3s1

# Switch between versions
kubectl config use-context k3d-k3s-v1-28
kubectl config use-context k3d-k3s-v1-27
```

## 🐛 Troubleshooting

### Cluster Creation Fails

```bash
# Check Docker is running
docker ps

# Check for port conflicts
sudo lsof -i :6443

# Delete and recreate
k3d cluster delete mycluster
k3d cluster create mycluster

# Create with verbose output
k3d cluster create mycluster --verbose
```

### Cannot Access Services

```bash
# Verify LoadBalancer
kubectl get svc

# Check if port mapping is correct
docker ps | grep k3d

# Test with port-forward
kubectl port-forward svc/my-service 8080:80

# Check k3d network
docker network inspect k3d-mycluster
```

### Registry Issues

```bash
# Check registry is running
docker ps | grep registry

# Test registry connectivity
curl http://localhost:5000/v2/_catalog

# Verify registry in cluster
kubectl run tmp --rm -it --image=curlimages/curl -- curl http://k3d-myregistry.localhost:5000/v2/_catalog
```

### Node Issues

```bash
# Check node status
kubectl get nodes

# Describe node
kubectl describe node k3d-mycluster-server-0

# Check k3d node containers
docker ps -a | grep k3d

# Restart containers if needed
docker restart k3d-mycluster-server-0
```

## 📊 Cluster Management

### Cluster Operations

```bash
# List all clusters
k3d cluster list

# Get cluster info
k3d cluster get mycluster

# Stop cluster (pause containers)
k3d cluster stop mycluster

# Start cluster
k3d cluster start mycluster

# Delete cluster
k3d cluster delete mycluster

# Delete all clusters
k3d cluster delete --all
```

### Node Management

```bash
# List nodes
k3d node list

# Create additional agent node
k3d node create mynewnode --cluster mycluster --role agent

# Delete node
k3d node delete k3d-mycluster-agent-0
```

### Registry Management

```bash
# List registries
k3d registry list

# Create registry
k3d registry create myregistry.localhost --port 5001

# Delete registry
k3d registry delete k3d-myregistry.localhost
```

## 🎓 Best Practices

1. **Use configuration files**: For reproducible environments
2. **Local registry**: Faster image loading and testing
3. **Port mapping**: Plan your port assignments
4. **Named clusters**: Use meaningful names
5. **Cleanup**: Delete unused clusters regularly
6. **CI/CD**: Excellent for automated testing
7. **Resource efficient**: Can run multiple clusters simultaneously

## 📚 Examples

### Complete Development Setup

```bash
# Create comprehensive dev cluster
k3d cluster create dev \
  --servers 1 \
  --agents 3 \
  --port 8080:80@loadbalancer \
  --port 8443:443@loadbalancer \
  --registry-create dev-registry:0.0.0.0:5000 \
  --volume /tmp/k3d:/tmp/k3d@all

# Export kubeconfig
k3d kubeconfig get dev > ~/.kube/k3d-dev-config

# Verify cluster
kubectl get nodes
kubectl get pods -A

# Test registry
docker pull nginx:alpine
docker tag nginx:alpine localhost:5000/nginx:alpine
docker push localhost:5000/nginx:alpine

# Deploy test app
kubectl create deployment nginx --image=localhost:5000/nginx:alpine
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Access via LoadBalancer
curl localhost:8080
```

## 🔗 Additional Resources

- [Official Documentation](https://k3d.io/)
- [GitHub Repository](https://github.com/k3d-io/k3d)
- [K3s Documentation](https://docs.k3s.io/)
- [Configuration Reference](https://k3d.io/v5.6.0/usage/configfile/)

## ⚡ Quick Reference

```bash
# Cluster Management
k3d cluster create <name>
k3d cluster create <name> --agents 3
k3d cluster list
k3d cluster start <name>
k3d cluster stop <name>
k3d cluster delete <name>

# With Options
k3d cluster create <name> \
  -p "8080:80@loadbalancer" \
  --agents 2 \
  --registry-create

# Image Management
k3d image import <image> -c <cluster>
k3d image import <image1> <image2> -c <cluster>

# Registry
k3d registry create <name> --port 5000
k3d registry list
k3d registry delete <name>

# Node Management
k3d node list
k3d node create <name> --cluster <cluster>
k3d node delete <name>

# Configuration
k3d kubeconfig get <cluster>
k3d cluster create --config config.yaml
```

---

**Next Steps**: After setting up k3d, explore deploying applications with the fast iteration cycle it provides.
