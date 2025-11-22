# Kubespray - Ansible-based Kubernetes Deployment

Kubespray is a composition of Ansible playbooks for deploying and managing production-ready Kubernetes clusters.

## 📋 Overview

- **Type**: Automated bare-metal/cloud deployment
- **Technology**: Ansible
- **Complexity**: Medium
- **Best For**: Large clusters, automation, production

## ✨ Features

- ✅ Highly available Kubernetes clusters
- ✅ Multiple CNI plugins
- ✅ Support for various operating systems
- ✅ Cloud provider integrations
- ✅ Offline deployment support
- ✅ Cluster lifecycle management

## 📦 Prerequisites

- Python 3.6+
- Ansible 2.12+
- SSH access to all nodes
- Target nodes with Ubuntu 20.04+, CentOS 7+, etc.

## 🚀 Installation

```bash
# Install Ansible
pip3 install ansible

# Clone Kubespray
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

# Install dependencies
pip3 install -r requirements.txt

# Copy sample inventory
cp -rfp inventory/sample inventory/mycluster

# Configure SSH access
ssh-copy-id user@node-ip

# Edit inventory
vi inventory/mycluster/hosts.yaml

# Deploy cluster
ansible-playbook -i inventory/mycluster/hosts.yaml --become cluster.yml
```

## 🔗 Additional Resources

- [Official Documentation](https://kubespray.io/)
- [GitHub Repository](https://github.com/kubernetes-sigs/kubespray)

## ⚡ Quick Reference

```bash
# Deploy
ansible-playbook -i inventory/mycluster/hosts.yaml --become cluster.yml

# Scale
ansible-playbook -i inventory/mycluster/hosts.yaml --become scale.yml

# Upgrade
ansible-playbook -i inventory/mycluster/hosts.yaml --become upgrade-cluster.yml
```

---

**Next Steps**: Kubespray provides production-grade automation for Kubernetes deployment.
