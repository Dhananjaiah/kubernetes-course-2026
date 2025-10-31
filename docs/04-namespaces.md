# Module 4: Namespaces

## Overview

Namespaces provide a mechanism for isolating groups of resources within a single Kubernetes cluster. This module covers how to use namespaces to organize and manage cluster resources effectively.

## Learning Objectives

By the end of this module, you will be able to:
- Understand what namespaces are and why they're important
- Work with default Kubernetes namespaces
- Create and manage custom namespaces
- Set resource quotas and limits per namespace
- Use namespaces for multi-tenancy

## Table of Contents

1. [What are Namespaces?](#what-are-namespaces)
2. [Default Namespaces](#default-namespaces)
3. [Creating Namespaces](#creating-namespaces)
4. [Resource Quotas](#resource-quotas)
5. [Working with Namespaces](#working-with-namespaces)

---

## What are Namespaces?

### Definition

A **namespace** is a logical folder inside a Kubernetes cluster that allows multiple teams or applications to share the same cluster without stepping on each other's names.

### Why Namespaces Matter

**1. Organization**
- Group all objects for an app/environment (e.g., `cloudmart-dev`, `cloudmart-prod`)
- Separate resources by team, project, or customer

**2. Logical Isolation**
- Limit who can see/change things with RBAC
- Pair with NetworkPolicies to restrict traffic
- Not a hard security boundary by themselves

**3. Quotas & Limits**
- Cap CPU/RAM/objects per team using ResourceQuota
- Prevent resource exhaustion by a single team
- Set default limits for containers

**4. Safer Operations**
- Delete/inspect at namespace level instead of whole cluster
- Reduce risk of accidentally affecting wrong resources

### What Namespaces Do NOT Do

**Important Limitations:**

❌ **Not a hard security boundary** by themselves
- You still need RBAC, NetworkPolicies, and security policies

❌ **Don't split compute**
- Scheduling is still cluster-wide
- Quotas help control usage but don't create separate clusters

❌ **Not for every resource**
- Some resources are cluster-scoped (nodes, persistent volumes, storage classes)

---

## Default Namespaces

Kubernetes creates four namespaces automatically:

### 1. default

**Purpose:** Where resources go if you don't specify a namespace

```bash
# These commands work in the default namespace
kubectl get pods
kubectl run nginx --image=nginx
```

**When to use:**
- Quick testing and experiments
- Learning Kubernetes
- Small, simple deployments

**Best practice:** Don't use for production; create dedicated namespaces

### 2. kube-system

**Purpose:** Contains Kubernetes system components

**What's inside:**
```bash
kubectl get pods -n kube-system
```
- kube-dns / CoreDNS
- kube-proxy
- Metrics server
- Dashboard
- Other cluster add-ons

**Best practice:** Don't deploy your apps here; reserved for system components

### 3. kube-public

**Purpose:** Readable by everyone (even unauthenticated users)

**What's inside:**
- Cluster information
- Public certificates

**Use case:** Resources that should be publicly accessible across the cluster

### 4. kube-node-lease

**Purpose:** Holds lease objects associated with each node

**What it does:**
- Node heartbeats
- Improves node health check performance

**Note:** System-managed; you typically don't interact with it

---

## Creating Namespaces

### Imperative Approach

```bash
# Create namespace
kubectl create namespace development
kubectl create namespace production
kubectl create namespace team-a

# Create with short form
kubectl create ns staging
```

### Declarative Approach (YAML)

**Basic Namespace:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
```

**Namespace with Labels:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    team: platform
    cost-center: engineering
```

**Creating from YAML:**
```bash
kubectl apply -f namespace.yaml
```

### Viewing Namespaces

```bash
# List all namespaces
kubectl get namespaces
kubectl get ns

# Show labels
kubectl get ns --show-labels

# Describe namespace
kubectl describe ns development
```

---

## Resource Quotas

Resource quotas limit the aggregate resource consumption per namespace.

### Why Resource Quotas?

- **Prevent resource exhaustion** by a single team or application
- **Fair resource sharing** across teams
- **Cost control** in multi-tenant environments
- **Capacity planning** for cluster resources

### Creating Resource Quotas

**Basic ResourceQuota:**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    # Limit number of resources
    pods: "10"
    services: "5"
    
    # Limit compute resources
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "8"
    limits.memory: "16Gi"
    
    # Limit storage
    persistentvolumeclaims: "5"
    requests.storage: "100Gi"
```

**Apply quota:**
```bash
kubectl apply -f resourcequota.yaml
```

### Complete Example with Namespace and Quota

```yaml
---
# Create namespace
apiVersion: v1
kind: Namespace
metadata:
  name: team-alpha
  labels:
    team: alpha
    environment: development

---
# Set resource quota for the namespace
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-alpha-quota
  namespace: team-alpha
spec:
  hard:
    pods: "20"
    requests.cpu: "10"
    requests.memory: "20Gi"
    limits.cpu: "20"
    limits.memory: "40Gi"
    services: "10"
    persistentvolumeclaims: "10"

---
# Set default limits for pods (LimitRange)
apiVersion: v1
kind: LimitRange
metadata:
  name: team-alpha-limits
  namespace: team-alpha
spec:
  limits:
  - max:
      cpu: "2"
      memory: "4Gi"
    min:
      cpu: "100m"
      memory: "128Mi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "200m"
      memory: "256Mi"
    type: Container
```

### Important Note

**When using ResourceQuota:** You MUST specify resource requests/limits in your Pod specs!

```yaml
# This will FAIL if ResourceQuota is set
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
  namespace: team-alpha
spec:
  containers:
  - name: nginx
    image: nginx
    # Missing: resources!

---
# This will SUCCEED
apiVersion: v1
kind: Pod
metadata:
  name: good-pod
  namespace: team-alpha
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        memory: "100Mi"
        cpu: "200m"
      limits:
        memory: "200Mi"
        cpu: "500m"
```

### Viewing Quotas

```bash
# View quota
kubectl get resourcequota -n team-alpha
kubectl describe resourcequota team-alpha-quota -n team-alpha

# View quota usage
kubectl get resourcequota team-alpha-quota -n team-alpha -o yaml
```

---

## Working with Namespaces

### Specifying Namespace in Commands

```bash
# Create resource in specific namespace
kubectl run nginx --image=nginx -n development
kubectl apply -f pod.yaml -n production

# Get resources from specific namespace
kubectl get pods -n development
kubectl get all -n production

# Get resources from all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A
```

### Setting Default Namespace

Instead of always specifying `-n namespace`:

```bash
# View current context
kubectl config current-context

# Set default namespace for current context
kubectl config set-context --current --namespace=development

# Verify
kubectl config view --minify | grep namespace:

# Now commands use development namespace by default
kubectl get pods  # Same as: kubectl get pods -n development
```

### Switching Between Namespaces

```bash
# Method 1: Change default namespace
kubectl config set-context --current --namespace=production

# Method 2: Use kubens (if installed)
kubens development
kubens production

# List namespaces with kubens
kubens
```

### Namespace in YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: development  # Specify namespace here
spec:
  containers:
  - name: nginx
    image: nginx
```

---

## Best Practices

### 1. Naming Conventions

Use clear, consistent naming:
```
team-<team-name>           # team-alpha, team-beta
<app>-<env>               # myapp-dev, myapp-prod
<customer>-<env>          # acme-corp-prod
```

### 2. Namespace-per-Environment

```
myapp-dev
myapp-staging
myapp-production
```

**Benefits:**
- Clear separation
- Different access controls per environment
- Isolated resource quotas

### 3. Namespace-per-Team

```
team-platform
team-data
team-frontend
```

**Benefits:**
- Team ownership
- Resource allocation per team
- Cost tracking by team

### 4. Labels and Annotations

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
    team: platform
    cost-center: "1234"
  annotations:
    owner: "platform-team@company.com"
    description: "Production environment for platform services"
```

### 5. Always Set Resource Quotas

Protect your cluster:
```yaml
# Every namespace should have:
- ResourceQuota    # Aggregate limits
- LimitRange      # Per-container defaults and limits
```

---

## Hands-On Lab

### Lab 1: Create and Use Namespaces

```bash
# 1. List existing namespaces
kubectl get namespaces

# 2. Create development namespace
kubectl create namespace development

# 3. Create production namespace from YAML
cat > prod-ns.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production
EOF
kubectl apply -f prod-ns.yaml

# 4. Create pod in development namespace
kubectl run nginx --image=nginx -n development

# 5. Create pod in production namespace
kubectl run nginx --image=nginx -n production

# 6. View pods in each namespace
kubectl get pods -n development
kubectl get pods -n production

# 7. View all pods across namespaces
kubectl get pods -A

# 8. Clean up
kubectl delete namespace development production
```

### Lab 2: Resource Quotas

```bash
# 1. Create namespace with quota
cat > namespace-with-quota.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: limited-ns
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: limited-ns
spec:
  hard:
    pods: "2"
    requests.cpu: "1"
    requests.memory: "1Gi"
    limits.cpu: "2"
    limits.memory: "2Gi"
EOF

kubectl apply -f namespace-with-quota.yaml

# 2. Try to create pod without resources (will fail)
kubectl run nginx --image=nginx -n limited-ns
# Should see: Error from server (Forbidden): pods "nginx" is forbidden

# 3. Create pod with resources (will succeed)
cat > pod-with-resources.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: limited-ns
spec:
  containers:
  - name: nginx
    image: nginx
    resources:
      requests:
        cpu: "200m"
        memory: "256Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
EOF

kubectl apply -f pod-with-resources.yaml

# 4. Check quota usage
kubectl describe resourcequota compute-quota -n limited-ns

# 5. Clean up
kubectl delete namespace limited-ns
```

---

## Summary

In this module, you learned:
- ✅ Namespaces provide logical isolation in Kubernetes clusters
- ✅ Default namespaces and their purposes
- ✅ How to create and manage custom namespaces
- ✅ Resource quotas prevent resource exhaustion
- ✅ LimitRanges set default resource constraints
- ✅ Best practices for namespace organization

### Key Takeaways

1. **Use namespaces for organization**, not hard security
2. **Always set resource quotas** in production
3. **One namespace per environment or team** is a good pattern
4. **Label namespaces** for cost tracking and automation
5. **RBAC + NetworkPolicies** complete the isolation story

## Next Steps

Now that you understand namespaces, learn about [Module 5: ReplicaSets](05-replicasets.md) to ensure your pods are always available!

## Additional Resources

- [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
- [Limit Ranges](https://kubernetes.io/docs/concepts/policy/limit-range/)

---

[← Previous: Pods](03-pods.md) | [Next: ReplicaSets →](05-replicasets.md)
