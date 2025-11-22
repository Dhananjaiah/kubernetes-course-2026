# kubeadm - Official Kubernetes Cluster Setup Tool

kubeadm is the official Kubernetes tool for bootstrapping a minimum viable Kubernetes cluster that conforms to best practices.

## 📋 Overview

- **Type**: Bare-metal/VM Kubernetes installation
- **Nodes**: Multi-node HA support
- **Complexity**: Medium
- **Best For**: Production clusters, on-premises, learning K8s internals

## ✨ Features

- ✅ Official Kubernetes tool
- ✅ Best practices built-in
- ✅ High availability support
- ✅ Certificate management
- ✅ Cluster upgrades
- ✅ Works on any infrastructure

## 📦 Prerequisites

- **OS**: Ubuntu 20.04+, Debian 10+, CentOS 7+, RHEL 7+
- **CPU**: 2 cores minimum
- **RAM**: 2GB minimum
- **Network**: Nodes must communicate on required ports

## 🚀 Installation

### Step 1: Prepare All Nodes

```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup sysctl params
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Install containerd
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

### Step 2: Install kubeadm, kubelet, kubectl

```bash
# Add Kubernetes repository
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install packages
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Step 3: Initialize Control Plane

```bash
# On control plane node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Step 4: Install Pod Network

```bash
# Install Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

# Or Flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Step 5: Join Worker Nodes

```bash
# On worker nodes (use command from init output)
sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## 🔗 Additional Resources

- [Official Documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Creating HA Clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

## ⚡ Quick Reference

```bash
# Initialize
sudo kubeadm init

# Join
sudo kubeadm join <ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Token management
kubeadm token create --print-join-command

# Reset
sudo kubeadm reset
```

---

**Next Steps**: kubeadm provides full control over your Kubernetes cluster.
