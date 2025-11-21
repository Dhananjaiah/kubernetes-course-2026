# Kubernetes Installation Methods

This directory contains comprehensive guides for installing Kubernetes in various environments, from local development to production-grade bare-metal clusters.

## 📚 Table of Contents

- [Overview](#overview)
- [Local / Laptop Installations](#local--laptop-installations)
- [Bare-Metal / VM Installations](#bare-metal--vm-installations)
- [Comparison Matrix](#comparison-matrix)
- [Choosing the Right Installation](#choosing-the-right-installation)

## Overview

Kubernetes can be installed in many different ways depending on your use case:

- **Local Development**: Quick setup for learning and testing
- **Production**: High-availability, scalable clusters
- **Edge Computing**: Lightweight installations for resource-constrained environments
- **Bare-Metal**: Maximum performance and control

## 📱 Local / Laptop Installations

Perfect for development, testing, and learning Kubernetes on your local machine.

| Installation | Description | Best For | Resource Usage |
|-------------|-------------|----------|----------------|
| [Minikube](local/minikube.md) | Single-node Kubernetes cluster | Beginners, testing | Medium |
| [kind](local/kind.md) | Kubernetes IN Docker | CI/CD, multi-node testing | Low |
| [k3d](local/k3d.md) | K3s in Docker | Fast setup, CI/CD | Low |
| [K3s](local/k3s.md) | Lightweight Kubernetes | Edge, IoT, low resources | Very Low |
| [MicroK8s](local/microk8s.md) | Canonical's minimal K8s | Ubuntu users, quick setup | Low |
| [Docker Desktop](local/docker-desktop.md) | Built-in Kubernetes | Mac/Windows users | Medium |
| [Rancher Desktop](local/rancher-desktop.md) | Container management + K8s | Docker Desktop alternative | Medium |
| [Colima](local/colima.md) | Container runtime + K8s | macOS, Docker alternative | Low |

## 🖥️ Bare-Metal / VM Installations

Production-grade installations for on-premises or cloud infrastructure.

| Installation | Description | Best For | Complexity |
|-------------|-------------|----------|------------|
| [kubeadm](bare-metal/kubeadm.md) | Official K8s setup tool | Production, manual control | Medium |
| [Kubespray](bare-metal/kubespray.md) | Ansible-based deployment | Large clusters, automation | Medium |
| [kOps](bare-metal/kops.md) | Kubernetes Operations | AWS, production | Medium |
| [Rancher RKE](bare-metal/rancher-rke.md) | Rancher Kubernetes Engine | Rancher ecosystem | Low |
| [Rancher RKE2](bare-metal/rancher-rke2.md) | Security-focused K8s | Government, compliance | Low |
| [Talos Linux](bare-metal/talos-linux.md) | Immutable OS for K8s | Security, GitOps | High |
| [Fedora CoreOS/Flatcar](bare-metal/coreos-flatcar.md) | Container-optimized OS | Production, automation | Medium |

## 🔍 Comparison Matrix

### Local Development Solutions

| Feature | Minikube | kind | k3d | K3s | MicroK8s |
|---------|----------|------|-----|-----|----------|
| Multi-node | ✅ | ✅ | ✅ | ❌ | ✅ |
| Load Balancer | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ingress | ✅ | ✅ | ✅ | ✅ | ✅ |
| GPU Support | ✅ | ❌ | ❌ | ✅ | ✅ |
| Startup Time | ~2 min | ~30s | ~20s | ~30s | ~1 min |
| Memory | 2GB+ | 512MB+ | 512MB+ | 512MB | 540MB |

### Production Solutions

| Feature | kubeadm | Kubespray | kOps | RKE/RKE2 | Talos |
|---------|---------|-----------|------|----------|-------|
| HA Support | ✅ | ✅ | ✅ | ✅ | ✅ |
| Automated | ❌ | ✅ | ✅ | ✅ | ✅ |
| Cloud Native | ❌ | ❌ | ✅ | ❌ | ✅ |
| Upgrade Path | ✅ | ✅ | ✅ | ✅ | ✅ |
| Complexity | Medium | Medium | High | Low | High |

## 🎯 Choosing the Right Installation

### For Learning Kubernetes
**Recommended**: Minikube or kind
- Easy to set up and use
- Good documentation and community support
- Supports most Kubernetes features

### For Local Development
**Recommended**: kind, k3d, or Docker Desktop
- Fast startup times
- Minimal resource usage
- Easy to reset and recreate

### For CI/CD Pipelines
**Recommended**: kind or k3d
- Lightweight and fast
- Runs in containers
- Easy to integrate with CI systems

### For Edge/IoT Devices
**Recommended**: K3s or MicroK8s
- Minimal resource requirements
- Small binary size
- Production-ready

### For Production On-Premises
**Recommended**: kubeadm, Kubespray, or RKE2
- Full Kubernetes features
- Production-grade reliability
- Strong community and enterprise support

### For Production in Cloud
**Recommended**: kOps (AWS) or managed services (EKS, GKE, AKS)
- Cloud-native integrations
- Automated management
- High availability

### For Maximum Security
**Recommended**: Talos Linux or RKE2
- Immutable infrastructure
- Security-hardened by default
- Compliance-ready (RKE2)

## 📖 Getting Started

1. Choose an installation method based on your needs
2. Follow the detailed guide in the respective subdirectory
3. Verify your installation with basic kubectl commands
4. Proceed to the course modules to learn Kubernetes

## 🔗 Additional Resources

- [Official Kubernetes Documentation](https://kubernetes.io/docs/)
- [CNCF Kubernetes Installers](https://www.cncf.io/projects/kubernetes/)
- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [Production Best Practices](https://kubernetes.io/docs/setup/best-practices/)

## 📝 Contributing

If you find issues or want to add more installation methods, please contribute:
1. Fork the repository
2. Add/update installation guides
3. Submit a pull request

---

**Note**: Installation guides are maintained to reflect current best practices and latest versions. Last updated: 2026.
