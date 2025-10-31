# Module 15: Taints & Tolerations

## Overview

Taints and tolerations work together to ensure pods are not scheduled onto inappropriate nodes. Taints repel pods, while tolerations allow pods to schedule on tainted nodes.

## Learning Objectives

- Understand taints and tolerations
- Apply taints to nodes
- Configure tolerations in pods
- Use taints for node dedication and eviction

## Concepts

### Taints

**Taints** are applied to nodes to repel pods that don't tolerate the taint.

**Syntax:**
```
key=value:effect
```

**Effects:**
- `NoSchedule`: Pods won't be scheduled (existing pods stay)
- `PreferNoSchedule`: Try to avoid scheduling (soft NoSchedule)
- `NoExecute`: Pods won't be scheduled AND existing pods evicted

### Tolerations

**Tolerations** are applied to pods to allow scheduling on tainted nodes.

## Taint Examples

### Apply Taints to Nodes

```bash
# Add taint (NoSchedule)
kubectl taint nodes node-1 key=value:NoSchedule

# Add taint (PreferNoSchedule)
kubectl taint nodes node-2 env=staging:PreferNoSchedule

# Add taint (NoExecute - evicts pods)
kubectl taint nodes node-3 maintenance=true:NoExecute

# View node taints
kubectl describe node node-1 | grep Taints

# Remove taint (note the minus sign)
kubectl taint nodes node-1 key=value:NoSchedule-
```

## Toleration Examples

### Basic Toleration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-toleration
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx
```

### Toleration Operators

**Equal (exact match):**
```yaml
tolerations:
- key: "environment"
  operator: "Equal"
  value: "production"
  effect: "NoSchedule"
```

**Exists (any value):**
```yaml
tolerations:
- key: "environment"
  operator: "Exists"
  effect: "NoSchedule"
```

**Tolerate all taints:**
```yaml
tolerations:
- operator: "Exists"  # No key specified = all taints
```

### NoExecute with tolerationSeconds

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: eviction-test
spec:
  tolerations:
  - key: "node.kubernetes.io/unreachable"
    operator: "Exists"
    effect: "NoExecute"
    tolerationSeconds: 300  # Stay for 5 minutes before eviction
  containers:
  - name: nginx
    image: nginx
```

## Common Use Cases

### 1. Dedicated Nodes

Reserve nodes for specific workloads.

```bash
# Taint node for GPU workloads
kubectl taint nodes gpu-node-1 workload=gpu:NoSchedule

# Label node
kubectl label nodes gpu-node-1 workload=gpu
```

```yaml
# GPU pod tolerates taint
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  nodeSelector:
    workload: gpu
  tolerations:
  - key: "workload"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  containers:
  - name: gpu-app
    image: tensorflow/tensorflow:latest-gpu
```

### 2. Node Maintenance

Prevent new pods during maintenance.

```bash
# Cordon (mark unschedulable) - same as NoSchedule taint
kubectl cordon node-1

# Drain (evict pods) - same as NoExecute taint
kubectl drain node-1 --ignore-daemonsets

# After maintenance
kubectl uncordon node-1
```

### 3. Special Hardware

Nodes with special hardware (SSD, GPU, etc).

```bash
kubectl taint nodes ssd-node-1 disk=ssd:NoSchedule
kubectl label nodes ssd-node-1 disk=ssd
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
spec:
  nodeSelector:
    disk: ssd
  tolerations:
  - key: "disk"
    operator: "Equal"
    value: "ssd"
    effect: "NoSchedule"
  containers:
  - name: db
    image: postgres:13
```

## Built-in Taints

Kubernetes automatically applies these taints:

```bash
# Node not ready
node.kubernetes.io/not-ready:NoExecute

# Node unreachable
node.kubernetes.io/unreachable:NoExecute

# Node out of disk
node.kubernetes.io/out-of-disk:NoSchedule

# Node memory pressure
node.kubernetes.io/memory-pressure:NoSchedule

# Node disk pressure
node.kubernetes.io/disk-pressure:NoSchedule

# Node network unavailable
node.kubernetes.io/network-unavailable:NoSchedule

# Node unschedulable
node.kubernetes.io/unschedulable:NoSchedule
```

### Default Tolerations

Kubernetes adds these tolerations automatically to all pods:

```yaml
tolerations:
- key: "node.kubernetes.io/not-ready"
  operator: "Exists"
  effect: "NoExecute"
  tolerationSeconds: 300

- key: "node.kubernetes.io/unreachable"
  operator: "Exists"
  effect: "NoExecute"
  tolerationSeconds: 300
```

## Hands-On Labs

### Lab 1: Basic Taint and Toleration

```bash
# Taint a node
kubectl taint nodes <node-name> app=special:NoSchedule

# Create pod WITHOUT toleration (won't schedule on tainted node)
kubectl run nginx-no-tol --image=nginx

# Check where it scheduled
kubectl get pod nginx-no-tol -o wide

# Create pod WITH toleration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-with-tol
spec:
  tolerations:
  - key: "app"
    operator: "Equal"
    value: "special"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx
EOF

# Check where it scheduled
kubectl get pod nginx-with-tol -o wide

# Remove taint
kubectl taint nodes <node-name> app=special:NoSchedule-
```

### Lab 2: NoExecute Effect

```bash
# Create pods
kubectl run test-1 --image=nginx
kubectl run test-2 --image=nginx

# Wait for pods to run
kubectl get pods -o wide

# Apply NoExecute taint (evicts pods)
kubectl taint nodes <node-with-pods> evict=true:NoExecute

# Watch pods get evicted and rescheduled
kubectl get pods -w
```

### Lab 3: Dedicated Node Pool

```bash
# Taint nodes for production
kubectl taint nodes prod-node-1 environment=production:NoSchedule
kubectl taint nodes prod-node-2 environment=production:NoSchedule

# Label nodes
kubectl label nodes prod-node-1 environment=production
kubectl label nodes prod-node-2 environment=production

# Deploy production app
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prod-app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: prod-app
  template:
    metadata:
      labels:
        app: prod-app
    spec:
      nodeSelector:
        environment: production
      tolerations:
      - key: "environment"
        operator: "Equal"
        value: "production"
        effect: "NoSchedule"
      containers:
      - name: app
        image: nginx
EOF

# Verify all pods on production nodes
kubectl get pods -l app=prod-app -o wide
```

## Best Practices

1. **Use taints for node dedication** - Reserve nodes for specific workloads
2. **Combine with nodeSelector** - Taint + label for complete control
3. **Use PreferNoSchedule for soft constraints** - Less disruptive
4. **Document taints** - Add labels or annotations explaining purpose
5. **Test eviction carefully** - NoExecute can disrupt services

## Taint vs Node Affinity

| Feature | Taints & Tolerations | Node Affinity |
|---------|---------------------|---------------|
| Direction | Node repels pods | Pod selects nodes |
| Default | Pods rejected | Pods can go anywhere |
| Eviction | Yes (NoExecute) | No |
| Use Case | Prevent scheduling | Select specific nodes |

## Key Takeaways

- **Taints repel pods** - Applied to nodes
- **Tolerations allow scheduling** - Applied to pods
- **NoSchedule**: Prevent new pods
- **NoExecute**: Evict existing pods
- **PreferNoSchedule**: Soft constraint
- **Combine with labels** - For complete node dedication
- **Built-in taints** - Kubernetes uses for node conditions

## Next Steps

- **[Module 16: Storage & Persistence](16-storage-persistence.md)**

## Additional Resources

- [Kubernetes Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
