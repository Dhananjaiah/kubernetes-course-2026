# Talos Linux - Immutable OS for Kubernetes

Talos Linux is a modern OS designed specifically for running Kubernetes, with immutable infrastructure and API-driven management.

## 📋 Overview

- **Type**: Immutable Kubernetes OS
- **Complexity**: High
- **Best For**: Security, GitOps, immutable infrastructure

## ✨ Features

- ✅ Immutable and minimal OS
- ✅ API-driven (no SSH)
- ✅ Secure by design
- ✅ Fast boot times
- ✅ Declarative configuration
- ✅ Built-in encryption

## 📦 Prerequisites

- Bare metal, VMs, or cloud
- talosctl CLI installed
- Boot media or PXE setup

## 🚀 Installation

```bash
# Install talosctl
curl -sL https://talos.dev/install | sh

# Generate configuration
talosctl gen config mycluster https://control-plane-ip:6443

# Apply configuration to nodes
talosctl apply-config --insecure \
  --nodes 192.168.1.10 \
  --file controlplane.yaml

talosctl apply-config --insecure \
  --nodes 192.168.1.11 \
  --file worker.yaml

# Bootstrap etcd
talosctl bootstrap --nodes 192.168.1.10

# Configure kubectl
talosctl kubeconfig --nodes 192.168.1.10
kubectl get nodes
```

## 🔗 Additional Resources

- [Official Documentation](https://www.talos.dev/docs/)
- [GitHub Repository](https://github.com/siderolabs/talos)

## ⚡ Quick Reference

```bash
# Generate config
talosctl gen config <cluster> <endpoint>

# Apply config
talosctl apply-config --nodes <ip> --file <config>

# Bootstrap
talosctl bootstrap --nodes <ip>

# Get kubeconfig
talosctl kubeconfig --nodes <ip>
```

---

**Next Steps**: Talos Linux provides immutable, secure Kubernetes infrastructure.
