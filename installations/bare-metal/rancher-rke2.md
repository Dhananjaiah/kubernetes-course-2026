# Rancher RKE2 - Security-Focused Kubernetes

RKE2 is Rancher's next-generation Kubernetes distribution, focused on security and compliance.

## 📋 Overview

- **Type**: Security-hardened Kubernetes
- **Complexity**: Low
- **Best For**: Government, compliance, production

## ✨ Features

- ✅ CIS Kubernetes Benchmark compliance
- ✅ FIPS 140-2 compliance option
- ✅ SELinux support
- ✅ Embedded etcd
- ✅ Minimal attack surface
- ✅ Easy upgrades

## 📦 Prerequisites

- RHEL, CentOS, Ubuntu, or SLES
- 2GB RAM minimum
- SELinux enforcing mode (recommended)

## 🚀 Installation

```bash
# Install RKE2 server
curl -sfL https://get.rke2.io | sh -

# Enable and start
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

# Setup kubeconfig
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin

# Verify
kubectl get nodes

# On worker nodes
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
sudo systemctl enable rke2-agent.service

# Configure and start
sudo mkdir -p /etc/rancher/rke2/
echo "server: https://<server-ip>:9345" | sudo tee /etc/rancher/rke2/config.yaml
echo "token: <token>" | sudo tee -a /etc/rancher/rke2/config.yaml
sudo systemctl start rke2-agent.service
```

## 🔗 Additional Resources

- [Official Documentation](https://docs.rke2.io/)
- [GitHub Repository](https://github.com/rancher/rke2)

## ⚡ Quick Reference

```bash
# Install server
curl -sfL https://get.rke2.io | sh -
sudo systemctl enable --now rke2-server.service

# Install agent
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
sudo systemctl enable --now rke2-agent.service
```

---

**Next Steps**: RKE2 provides security-hardened Kubernetes for compliance requirements.
