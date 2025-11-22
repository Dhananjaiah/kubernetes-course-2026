# kOps - Kubernetes Operations

kOps is the easiest way to create, destroy, upgrade, and maintain production-grade Kubernetes clusters on AWS and other clouds.

## 📋 Overview

- **Type**: Cloud-native Kubernetes deployment
- **Platform**: AWS (primary), GCP, DigitalOcean
- **Complexity**: Medium
- **Best For**: AWS deployments, production clusters

## ✨ Features

- ✅ Automated cluster provisioning
- ✅ High availability out of the box
- ✅ Rolling cluster updates
- ✅ Multiple instance groups
- ✅ Cluster validation
- ✅ Managed etcd

## 📦 Prerequisites

- AWS account with IAM permissions
- AWS CLI configured
- kubectl installed
- Domain name (Route53 or DNS)
- S3 bucket for state storage

## 🚀 Installation

```bash
# Install kOps
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops
sudo mv kops /usr/local/bin/

# Create S3 bucket
aws s3 mb s3://my-kops-state-store
export KOPS_STATE_STORE=s3://my-kops-state-store

# Create cluster
export NAME=mycluster.k8s.local
kops create cluster \
  --name=${NAME} \
  --zones=us-east-1a \
  --master-count=1 \
  --node-count=2

kops update cluster ${NAME} --yes
kops validate cluster --wait 10m
```

## 🔗 Additional Resources

- [Official Documentation](https://kops.sigs.k8s.io/)
- [GitHub Repository](https://github.com/kubernetes/kops)

## ⚡ Quick Reference

```bash
# Create
kops create cluster --name=${NAME} --zones=us-east-1a
kops update cluster ${NAME} --yes

# Validate
kops validate cluster

# Delete
kops delete cluster ${NAME} --yes
```

---

**Next Steps**: kOps is perfect for production Kubernetes on AWS.
