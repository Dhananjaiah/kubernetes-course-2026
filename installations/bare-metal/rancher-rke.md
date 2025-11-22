# Rancher RKE - Rancher Kubernetes Engine

RKE is a CNCF-certified Kubernetes distribution that runs entirely within Docker containers.

## 📋 Overview

- **Type**: Docker-based Kubernetes
- **Complexity**: Low
- **Best For**: Rancher ecosystem, simple deployments

## ✨ Features

- ✅ Runs entirely in Docker
- ✅ Simple YAML configuration
- ✅ Multi-node support
- ✅ Automated TLS certificates
- ✅ Easy upgrades
- ✅ Rancher integration

## 📦 Prerequisites

- Docker installed on all nodes
- SSH access to nodes
- Ports 6443, 2379-2380, 10250-10252 open

## 🚀 Installation

```bash
# Download RKE
curl -LO https://github.com/rancher/rke/releases/download/v1.4.0/rke_linux-amd64
chmod +x rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke

# Create cluster.yml
cat > cluster.yml <<EOF
nodes:
  - address: 192.168.1.10
    user: ubuntu
    role: [controlplane,etcd,worker]
  - address: 192.168.1.11
    user: ubuntu
    role: [worker]
EOF

# Deploy cluster
rke up

# Configure kubectl
export KUBECONFIG=$(pwd)/kube_config_cluster.yml
kubectl get nodes
```

## 🔗 Additional Resources

- [Official Documentation](https://rancher.com/docs/rke/latest/en/)
- [GitHub Repository](https://github.com/rancher/rke)

## ⚡ Quick Reference

```bash
# Deploy
rke up

# Remove
rke remove

# Upgrade
rke up --config cluster.yml
```

---

**Next Steps**: RKE is perfect for Rancher-managed Kubernetes deployments.
