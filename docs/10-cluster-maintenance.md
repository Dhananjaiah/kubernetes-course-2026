# Module 10: Cluster Maintenance

## Overview

Cluster maintenance involves managing nodes, performing upgrades, handling node failures, and ensuring high availability during maintenance windows. This module covers essential cluster maintenance tasks.

## Learning Objectives

- Drain and cordon nodes for maintenance
- Perform cluster upgrades safely
- Handle node failures gracefully
- Scale cluster nodes
- Backup and restore cluster state

## Key Concepts

### Node Operations

**Cordon**: Mark node as unschedulable (no new pods)
```bash
kubectl cordon <node-name>
```

**Uncordon**: Mark node as schedulable again
```bash
kubectl uncordon <node-name>
```

**Drain**: Safely evict pods from node (for maintenance)
```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Maintenance Workflow

```
1. Cordon node (prevent new pods)
   kubectl cordon node-1

2. Drain node (evict existing pods)
   kubectl drain node-1 --ignore-daemonsets

3. Perform maintenance (OS updates, hardware fixes)
   # System maintenance happens here

4. Uncordon node (allow scheduling)
   kubectl uncordon node-1
```

### Cluster Upgrade Strategy

1. Backup etcd
2. Upgrade control plane components
3. Upgrade worker nodes (one at a time)
4. Verify cluster health

```bash
# Check current version
kubectl version

# Drain node
kubectl drain node-1 --ignore-daemonsets

# Upgrade node (kubeadm example)
# SSH to node
sudo apt-get update
sudo apt-get install -y kubeadm=1.28.0-00
sudo kubeadm upgrade node
sudo apt-get install -y kubelet=1.28.0-00
sudo systemctl restart kubelet

# Uncordon node
kubectl uncordon node-1
```

## Hands-On Labs

### Lab: Drain and Uncordon Node

```bash
# View nodes
kubectl get nodes

# Cordon node
kubectl cordon <node-name>

# Check node status (should show SchedulingDisabled)
kubectl get nodes

# Drain node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Verify pods moved to other nodes
kubectl get pods -o wide

# Uncordon node
kubectl uncordon <node-name>

# Verify node is schedulable
kubectl get nodes
```

## Key Takeaways

- Always drain nodes before maintenance
- Use `--ignore-daemonsets` flag when draining
- Upgrade one node at a time
- Backup etcd before cluster upgrades
- Monitor pod distribution during maintenance

## Next Steps

- **[Module 11: DaemonSets, Jobs & CronJobs](11-daemonsets-jobs-cronjobs.md)**
