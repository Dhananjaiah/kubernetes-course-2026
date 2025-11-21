# Docker Desktop Kubernetes

Docker Desktop includes a standalone Kubernetes server and client that runs on your local machine, providing an easy way to test Kubernetes deployments.

## 📋 Overview

- **Type**: Desktop Kubernetes
- **Nodes**: Single-node
- **Resource Usage**: Medium (2GB+ RAM)
- **Startup Time**: ~1 minute
- **Best For**: Mac/Windows users, Docker integration

## ✨ Features

- ✅ Integrated with Docker Desktop
- ✅ One-click enable/disable
- ✅ Automatic kubectl installation
- ✅ Seamless Docker integration
- ✅ LoadBalancer support via localhost
- ✅ Easy cluster reset
- ✅ Automatic updates
- ✅ Windows and macOS support

## 📦 Prerequisites

### System Requirements
- **Windows**: Windows 10/11 Pro, Enterprise, or Education (64-bit)
  - WSL 2 feature enabled
  - 4GB RAM minimum
- **macOS**: macOS 10.15 or later
  - 4GB RAM minimum
- **Disk Space**: 20GB+ available

## 🚀 Installation

### Windows

```powershell
# Download Docker Desktop from:
# https://www.docker.com/products/docker-desktop

# Install using the installer
# Or use winget:
winget install Docker.DockerDesktop

# After installation, restart your computer

# Verify installation
docker version
```

### macOS

```bash
# Download from Docker website:
# https://www.docker.com/products/docker-desktop

# Or install using Homebrew
brew install --cask docker

# Launch Docker Desktop from Applications
# Or from terminal:
open -a Docker

# Verify installation
docker version
```

### Linux

```bash
# Docker Desktop for Linux is available for:
# Ubuntu, Debian, Fedora

# Download the DEB package (Ubuntu/Debian):
# https://docs.docker.com/desktop/install/linux-install/

# Install
sudo apt-get install ./docker-desktop-<version>-<arch>.deb

# Or for Fedora/RHEL:
sudo dnf install ./docker-desktop-<version>-<arch>.rpm
```

## ⚙️ Enable Kubernetes

### Via GUI

1. Open Docker Desktop
2. Click on **Settings** (gear icon)
3. Navigate to **Kubernetes** tab
4. Check **Enable Kubernetes**
5. Click **Apply & Restart**
6. Wait for Kubernetes to start (green indicator)

### Verify Installation

```bash
# Check Docker
docker version
docker ps

# Check Kubernetes
kubectl cluster-info
kubectl get nodes

# Should show:
# NAME             STATUS   ROLE           AGE   VERSION
# docker-desktop   Ready    control-plane  1m    v1.28.x
```

## 🔧 Configuration

### Resource Allocation

**Via GUI:**
1. Open Docker Desktop Settings
2. Go to **Resources**
3. Adjust:
   - CPUs: 2-4 cores recommended
   - Memory: 4-8 GB recommended
   - Disk: 20+ GB
4. Click **Apply & Restart**

### kubectl Context

```bash
# Check current context
kubectl config current-context
# Should show: docker-desktop

# List all contexts
kubectl config get-contexts

# Switch to Docker Desktop
kubectl config use-context docker-desktop

# View context details
kubectl config view
```

### Kubernetes Version

```bash
# Check version
kubectl version --short

# Docker Desktop includes specific K8s version
# Updates come with Docker Desktop updates
```

## 🐳 Working with Images

### Using Local Docker Images

```bash
# Build image locally
docker build -t my-app:v1 .

# List images
docker images

# Use directly in Kubernetes (no push needed)
kubectl run my-app --image=my-app:v1 --image-pull-policy=Never

# Or in deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:v1
        imagePullPolicy: Never
EOF
```

### Image Pull Policy

```yaml
# For local images, use one of:
imagePullPolicy: Never        # Never pull, use local only
imagePullPolicy: IfNotPresent # Pull if not present locally
imagePullPolicy: Always       # Always pull from registry
```

## 🔌 Networking and Services

### LoadBalancer Services

```bash
# LoadBalancer automatically works via localhost
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get service details
kubectl get svc nginx

# Access via localhost
curl http://localhost:80

# Or get assigned port if 80 is in use
kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}'
```

### Port Forwarding

```bash
# Forward local port to pod
kubectl port-forward pod/my-pod 8080:80

# Forward to service
kubectl port-forward svc/my-service 8080:80

# Forward to deployment
kubectl port-forward deployment/my-app 8080:80
```

### Ingress Controller

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

# Wait for ingress controller
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Create ingress resource
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: app.local
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

# Add to hosts file
# Windows: C:\Windows\System32\drivers\etc\hosts
# Mac/Linux: /etc/hosts
echo "127.0.0.1 app.local" | sudo tee -a /etc/hosts

# Access
curl http://app.local
```

## 📊 Storage

### Persistent Volumes

```bash
# Docker Desktop provides hostPath storage by default

# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Use in pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: my-pvc
EOF
```

### Host Path Volumes

```bash
# Mount host directory (limited in Docker Desktop)
# On Mac: /Users, /Volumes, /private, /tmp
# On Windows: C:\Users

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: host-volume
      mountPath: /data
  volumes:
  - name: host-volume
    hostPath:
      path: /Users/username/data  # Adjust path
      type: DirectoryOrCreate
EOF
```

## 🎯 Common Use Cases

### Local Development

```bash
# 1. Build image
docker build -t my-app:dev .

# 2. Deploy to Kubernetes
kubectl create deployment my-app --image=my-app:dev
kubectl set image deployment/my-app my-app=my-app:dev --image-pull-policy=Never

# 3. Expose service
kubectl expose deployment my-app --port=8080 --type=LoadBalancer

# 4. Test
curl http://localhost:8080

# 5. Iterate (rebuild and restart)
docker build -t my-app:dev .
kubectl rollout restart deployment/my-app
```

### Testing Helm Charts

```bash
# Install Helm (if not already)
# Windows:
choco install kubernetes-helm

# macOS:
brew install helm

# Use with Docker Desktop
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Install chart
helm install my-release stable/nginx-ingress

# Test
kubectl get all
```

## 🐛 Troubleshooting

### Kubernetes Won't Start

```bash
# 1. Reset Kubernetes cluster
# Docker Desktop Settings > Kubernetes > Reset Kubernetes Cluster

# 2. Restart Docker Desktop
# System tray icon > Quit Docker Desktop
# Launch Docker Desktop again

# 3. Check Docker resources
# Settings > Resources > Increase memory/CPU

# 4. Clear Docker data (last resort)
# Settings > Troubleshoot > Clean / Purge data
```

### Pods Not Starting

```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check Docker
docker ps -a

# Check logs
kubectl logs <pod-name>
```

### Service Not Accessible

```bash
# Verify service
kubectl get svc

# Check endpoints
kubectl get endpoints

# Test with port-forward
kubectl port-forward svc/my-service 8080:80

# Check firewall settings (Windows)
# Windows Security > Firewall & network protection
```

### Image Pull Issues

```bash
# For local images, ensure:
# 1. Image exists in Docker
docker images | grep my-app

# 2. Use correct pull policy
imagePullPolicy: Never  # or IfNotPresent

# 3. Verify image name matches exactly
kubectl describe pod <pod-name> | grep Image
```

## 🔄 Cluster Management

### Reset Cluster

```bash
# Via GUI:
# Settings > Kubernetes > Reset Kubernetes Cluster

# This will:
# - Delete all resources
# - Reset to clean state
# - Keep Docker images
```

### Enable/Disable Kubernetes

```bash
# Via GUI:
# Settings > Kubernetes > Enable/Disable Kubernetes

# When disabled:
# - Saves resources
# - Preserves cluster state
# - Can be re-enabled quickly
```

### Updates

```bash
# Kubernetes version updates with Docker Desktop
# Check for updates:
# Docker Desktop > Check for Updates

# Or enable automatic updates
# Settings > General > Automatically check for updates
```

## 🎓 Best Practices

1. **Resource allocation**: Allocate sufficient CPU/RAM
2. **Use local images**: Faster development cycle
3. **LoadBalancer**: Use for easy service access
4. **Reset when needed**: Clean slate for testing
5. **Context switching**: Manage multiple contexts carefully
6. **Cleanup**: Delete unused resources to save memory
7. **Updates**: Keep Docker Desktop updated

## 📚 Examples

### Complete Development Workflow

```bash
# 1. Setup
kubectl config use-context docker-desktop

# 2. Create namespace
kubectl create namespace dev

# 3. Build application
docker build -t my-app:v1 .

# 4. Deploy
cat <<EOF | kubectl apply -n dev -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: my-app
EOF

# 5. Verify
kubectl get all -n dev
curl http://localhost

# 6. Cleanup
kubectl delete namespace dev
```

## 🔗 Additional Resources

- [Docker Desktop Documentation](https://docs.docker.com/desktop/)
- [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)
- [Docker Hub](https://hub.docker.com/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)

## ⚡ Quick Reference

```bash
# Cluster Info
kubectl config use-context docker-desktop
kubectl cluster-info
kubectl get nodes

# Resource Management
docker stats
docker system df
docker system prune

# Image Management
docker images
docker build -t <image>:<tag> .
docker rmi <image>

# Deployment
kubectl create deployment <name> --image=<image>
kubectl expose deployment <name> --port=<port> --type=LoadBalancer

# Troubleshooting
kubectl get events
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Cleanup
kubectl delete all --all -n <namespace>
# Docker Desktop > Reset Kubernetes Cluster
```

---

**Next Steps**: Docker Desktop provides an excellent platform for learning Kubernetes. Perfect for following the course modules with a familiar Docker environment.
