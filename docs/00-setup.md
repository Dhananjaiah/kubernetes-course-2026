# Setup Guide - Kubernetes Course 2026

This guide will help you set up your local development environment for the Kubernetes course. By the end of this guide, you'll have all the tools needed to run Kubernetes locally and complete the course labs.

## System Requirements

### Minimum Requirements
- **CPU**: 2 cores
- **RAM**: 8 GB
- **Disk Space**: 20 GB free
- **Operating System**: Linux, macOS, or Windows 10+

### Recommended Requirements
- **CPU**: 4 cores or more
- **RAM**: 16 GB or more
- **Disk Space**: 50 GB free
- **Operating System**: Linux or macOS

## Required Tools

### 1. Docker Installation

Docker is required for building and running containers.

#### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add your user to docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
```

#### macOS
```bash
# Download Docker Desktop from:
# https://www.docker.com/products/docker-desktop

# Or use Homebrew
brew install --cask docker

# Verify installation
docker --version
```

#### Windows
1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Run the installer
3. Restart your computer
4. Verify installation in PowerShell:
   ```powershell
   docker --version
   ```

### 2. kubectl Installation

kubectl is the Kubernetes command-line tool.

#### Linux
```bash
# Download latest release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

#### macOS
```bash
# Using Homebrew
brew install kubectl

# Verify installation
kubectl version --client
```

#### Windows
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Or download manually from:
# https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe

# Verify installation
kubectl version --client
```

### 3. Minikube Installation

Minikube runs a single-node Kubernetes cluster locally.

#### Linux
```bash
# Download minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

#### macOS
```bash
# Using Homebrew
brew install minikube

# Verify installation
minikube version
```

#### Windows
```powershell
# Using Chocolatey
choco install minikube

# Or download installer from:
# https://minikube.sigs.k8s.io/docs/start/

# Verify installation
minikube version
```

### 4. Optional Tools

#### Helm (for Module 21)
```bash
# Linux/macOS
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows (Chocolatey)
choco install kubernetes-helm

# Verify
helm version
```

#### k9s (Terminal UI for Kubernetes)
```bash
# Linux/macOS
brew install derailed/k9s/k9s

# Windows (Chocolatey)
choco install k9s

# Verify
k9s version
```

## Setting Up Your Kubernetes Cluster

### Starting Minikube

```bash
# Start minikube with recommended settings
minikube start --cpus=2 --memory=4096 --driver=docker

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

### Configuring kubectl

```bash
# Enable kubectl autocompletion (bash)
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc

# Create alias for kubectl
echo 'alias k=kubectl' >> ~/.bashrc
source ~/.bashrc

# Verify connection to cluster
kubectl get pods -A
```

### Testing Your Setup

Run these commands to verify everything is working:

```bash
# 1. Check Docker
docker run hello-world

# 2. Check Kubernetes cluster
kubectl get nodes

# 3. Create a test pod
kubectl run test-pod --image=nginx --port=80

# 4. Check pod status
kubectl get pods

# 5. Clean up
kubectl delete pod test-pod
```

## Troubleshooting

### Docker Issues

**Problem**: Docker daemon not running
```bash
# Linux
sudo systemctl start docker
sudo systemctl enable docker

# macOS/Windows
# Start Docker Desktop application
```

**Problem**: Permission denied
```bash
# Linux - add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

### Minikube Issues

**Problem**: Minikube won't start
```bash
# Delete and recreate cluster
minikube delete
minikube start --cpus=2 --memory=4096 --driver=docker
```

**Problem**: Not enough resources
```bash
# Start with minimal resources
minikube start --cpus=2 --memory=2048
```

**Problem**: Driver issues
```bash
# List available drivers
minikube start --help | grep driver

# Try different driver
minikube start --driver=virtualbox
# or
minikube start --driver=hyperkit  # macOS
```

### kubectl Issues

**Problem**: kubectl not connecting to cluster
```bash
# Check current context
kubectl config current-context

# Set correct context
kubectl config use-context minikube

# View all contexts
kubectl config get-contexts
```

## Useful Commands Reference

```bash
# Minikube
minikube status           # Check cluster status
minikube stop            # Stop cluster
minikube delete          # Delete cluster
minikube dashboard       # Open Kubernetes dashboard
minikube ip              # Get cluster IP

# kubectl
kubectl version          # Check versions
kubectl cluster-info     # Cluster information
kubectl get nodes        # List nodes
kubectl get pods -A      # List all pods in all namespaces
kubectl config view      # View kubeconfig

# Docker
docker ps                # List running containers
docker images            # List images
docker system prune -a   # Clean up unused resources
```

## Next Steps

Once your environment is set up:

1. ✅ All tools are installed and working
2. ✅ Minikube cluster is running
3. ✅ kubectl can connect to the cluster
4. ✅ Test pod successfully created and deleted

You're ready to start the course! Proceed to [Module 1: Docker & Containers](01-docker-containers.md)

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)

---

**Need Help?** Open an issue in the repository or check the troubleshooting section above.
