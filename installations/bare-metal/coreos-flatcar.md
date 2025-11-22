# Fedora CoreOS / Flatcar + kubeadm

Container-optimized Linux distributions designed for running containerized workloads at scale.

## 📋 Overview

- **Type**: Container-optimized OS
- **Complexity**: Medium
- **Best For**: Production, automation, container-first

## ✨ Features

- ✅ Container-optimized
- ✅ Automatic updates
- ✅ Immutable infrastructure
- ✅ Ignition for provisioning
- ✅ Systemd integration

## 📦 Prerequisites

- Fedora CoreOS or Flatcar Linux ISO/image
- Ignition configuration
- kubeadm, kubelet, kubectl

## 🚀 Installation with Fedora CoreOS

```bash
# Create Ignition config (butane format)
cat > config.bu <<EOF
variant: fcos
version: 1.4.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ssh-rsa AAAA...
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: node1
systemd:
  units:
    - name: kubelet.service
      enabled: true
EOF

# Convert to Ignition
butane --pretty --strict < config.bu > config.ign

# Install FCOS with Ignition
# Boot from ISO with ignition.config.url parameter

# After boot, install Kubernetes
sudo rpm-ostree install kubelet kubeadm kubectl
sudo systemctl reboot

# Initialize with kubeadm
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

## 🚀 Installation with Flatcar

```bash
# Similar process with Flatcar-specific ignition

# Install Container Linux Config Transpiler
wget https://github.com/flatcar/container-linux-config-transpiler/releases/download/v0.9.0/ct-v0.9.0-x86_64-unknown-linux-gnu
chmod +x ct-v0.9.0-x86_64-unknown-linux-gnu
sudo mv ct-v0.9.0-x86_64-unknown-linux-gnu /usr/local/bin/ct

# Create and convert config
ct < config.yaml > config.ign

# Use ignition with Flatcar installation
```

## 🔗 Additional Resources

- [Fedora CoreOS Docs](https://docs.fedoraproject.org/en-US/fedora-coreos/)
- [Flatcar Documentation](https://www.flatcar.org/docs/latest/)
- [Ignition Specification](https://coreos.github.io/ignition/)

## ⚡ Quick Reference

```bash
# Convert butane to ignition
butane --pretty --strict < config.bu > config.ign

# Install packages (FCOS)
sudo rpm-ostree install <package>
sudo systemctl reboot

# kubeadm operations
sudo kubeadm init
sudo kubeadm join
```

---

**Next Steps**: CoreOS/Flatcar provide container-optimized operating systems for Kubernetes.
