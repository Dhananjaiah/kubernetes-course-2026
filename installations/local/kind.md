# kind - Kubernetes IN Docker

kind (Kubernetes IN Docker) is a tool for running local Kubernetes clusters using Docker containers as nodes. It's primarily designed for testing Kubernetes itself but is excellent for local development and CI/CD pipelines.

## 📋 Overview

- **Type**: Local development cluster
- **Nodes**: Multi-node support (default)
- **Resource Usage**: Low (512MB+ RAM per node)
- **Startup Time**: ~30 seconds
- **Best For**: CI/CD, multi-node testing, quick iterations

## ✨ Features

- ✅ Fast cluster creation (~30 seconds)
- ✅ Multi-node clusters by default
- ✅ Runs entirely in Docker containers
- ✅ No VM overhead
- ✅ Excellent for CI/CD pipelines
- ✅ Support for multiple clusters simultaneously
- ✅ Custom node images
- ✅ Port mapping for ingress

## 📦 Prerequisites

- Docker installed and running
- kubectl installed
- 2GB+ RAM available
- Docker API version 1.24+

## 🚀 Installation

### Linux

```bash
# Download latest release
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64

# Make executable
chmod +x ./kind

# Move to PATH
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

### macOS

```bash
# Using Homebrew
brew install kind

# Or download manually
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-darwin-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

### Windows

```powershell
# Using Chocolatey
choco install kind

# Or download manually from:
# https://github.com/kubernetes-sigs/kind/releases

# Verify installation
kind version
```

## ⚙️ Quick Start

### Create a Cluster

```bash
# Create default cluster
kind create cluster

# Create cluster with custom name
kind create cluster --name dev-cluster

# List clusters
kind get clusters

# Delete cluster
kind delete cluster --name dev-cluster
```

### Verify Installation

```bash
# Check cluster info
kubectl cluster-info --context kind-kind

# Get nodes
kubectl get nodes

# Get pods across all namespaces
kubectl get pods -A
```

## 🔧 Configuration

### Multi-Node Cluster

Create a config file `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

Create cluster with config:

```bash
kind create cluster --config kind-config.yaml --name multi-node
```

### Cluster with Ingress

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
```

Deploy ingress controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

### High Availability Control Plane

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
```

### Custom Kubernetes Version

```bash
# List available node images
curl -s https://hub.docker.com/v2/repositories/kindest/node/tags | jq -r '.results[].name'

# Create cluster with specific version
kind create cluster --image kindest/node:v1.28.0

# Or in config file
```

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.28.0
```

## 🐳 Working with Local Images

### Load Images into Cluster

```bash
# Build your image
docker build -t my-app:v1 .

# Load into kind cluster
kind load docker-image my-app:v1

# Load into specific cluster
kind load docker-image my-app:v1 --name dev-cluster

# Verify image is loaded
docker exec -it <node-container> crictl images
```

### Load from Archive

```bash
# Save image
docker save my-app:v1 > my-app.tar

# Load into kind
kind load image-archive my-app.tar
```

## 🔌 Networking

### Access Services

```bash
# Port-forward to access services
kubectl port-forward svc/my-service 8080:80

# Or use kubectl proxy
kubectl proxy
```

### LoadBalancer Services

kind doesn't support LoadBalancer services by default. Options:

**Option 1: Use NodePort**
```bash
kubectl expose deployment nginx --type=NodePort --port=80

# Get the node port
kubectl get svc nginx

# Access via Docker container
docker ps  # Find node container
docker inspect <container-id> | grep IPAddress
```

**Option 2: Install MetalLB**
```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# Wait for MetalLB pods
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=90s

# Configure address pool
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.19.255.200-172.19.255.250
EOF
```

## 🎯 Common Use Cases

### CI/CD Integration

```yaml
# GitHub Actions example
name: Test
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Create k8s Kind Cluster
      uses: helm/kind-action@v1.5.0
    - name: Run tests
      run: |
        kubectl cluster-info
        kubectl apply -f manifests/
        kubectl wait --for=condition=ready pod -l app=myapp
```

### Multi-Cluster Testing

```bash
# Create multiple clusters
kind create cluster --name cluster1
kind create cluster --name cluster2
kind create cluster --name cluster3

# Switch between clusters
kubectl config use-context kind-cluster1
kubectl config use-context kind-cluster2

# Delete all clusters
kind delete clusters --all
```

### Local Registry

```bash
# Create registry container
docker run -d --restart=always -p 5000:5000 --name kind-registry registry:2

# Create cluster connected to registry
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
    endpoint = ["http://kind-registry:5000"]
EOF

# Connect registry to cluster network
docker network connect kind kind-registry

# Use the registry
docker tag my-app:v1 localhost:5000/my-app:v1
docker push localhost:5000/my-app:v1

# Deploy using registry image
kubectl create deployment my-app --image=localhost:5000/my-app:v1
```

## 🐛 Troubleshooting

### Cluster Creation Fails

```bash
# Check Docker is running
docker ps

# Clean up previous attempts
kind delete cluster
docker system prune

# Check available resources
docker info | grep -i memory

# Create with verbose output
kind create cluster --verbosity=3
```

### Cannot Access Services

```bash
# Verify service is running
kubectl get svc

# Check endpoints
kubectl get endpoints

# Port forward to test
kubectl port-forward svc/my-service 8080:80

# Check network connectivity
kubectl run tmp-shell --rm -it --image=nicolaka/netshoot -- /bin/bash
curl my-service
```

### Image Not Found

```bash
# Verify image is loaded
docker exec kind-control-plane crictl images

# Load image again
kind load docker-image my-app:v1

# Use correct image pull policy
imagePullPolicy: Never  # or IfNotPresent
```

### Node Not Ready

```bash
# Check node status
kubectl get nodes
kubectl describe node kind-control-plane

# Check node logs
docker logs kind-control-plane

# Restart cluster
kind delete cluster
kind create cluster
```

## 📊 Cluster Management

### Export Cluster Logs

```bash
# Export logs for debugging
kind export logs --name kind

# Logs are saved to ./kind-logs/
```

### Export kubeconfig

```bash
# Export to specific file
kind get kubeconfig --name kind > ~/.kube/kind-config

# Use with kubectl
kubectl --kubeconfig ~/.kube/kind-config get nodes
```

### Cluster Lifecycle

```bash
# Create
kind create cluster --name my-cluster

# Stop (Docker containers)
docker stop kind-control-plane kind-worker kind-worker2

# Start
docker start kind-control-plane kind-worker kind-worker2

# Delete
kind delete cluster --name my-cluster
```

## 🎓 Best Practices

1. **Use configuration files**: For reproducible clusters
2. **Tag clusters by purpose**: Use meaningful names
3. **Cleanup regularly**: `kind delete clusters --all`
4. **Use local registry**: For faster image loading
5. **CI/CD integration**: Excellent for testing
6. **Port mappings**: Configure ingress properly
7. **Resource limits**: Don't create too many nodes

## 📚 Examples

### Complete Development Cluster

```yaml
# dev-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: dev
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
- role: worker
- role: worker
```

```bash
# Create cluster
kind create cluster --config dev-cluster.yaml

# Install ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for ingress
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Test ingress
curl localhost:8080
```

## 🔗 Additional Resources

- [Official Documentation](https://kind.sigs.k8s.io/)
- [GitHub Repository](https://github.com/kubernetes-sigs/kind)
- [Configuration Reference](https://kind.sigs.k8s.io/docs/user/configuration/)
- [Ingress Guide](https://kind.sigs.k8s.io/docs/user/ingress/)

## ⚡ Quick Reference

```bash
# Cluster Operations
kind create cluster
kind create cluster --name <name>
kind create cluster --config <file>
kind get clusters
kind delete cluster --name <name>
kind delete clusters --all

# Images
kind load docker-image <image>
kind load docker-image <image> --name <cluster>
kind load image-archive <tar-file>

# Configuration
kind get kubeconfig --name <name>
kind export logs --name <name>

# Nodes
kind get nodes --name <name>

# Useful with kubectl
kubectl cluster-info --context kind-<cluster-name>
kubectl config use-context kind-<cluster-name>
```

---

**Next Steps**: After setting up kind, try deploying the microservices project from [microservices/README.md](../../microservices/README.md).
