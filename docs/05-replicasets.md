# Module 5: ReplicaSets

## Overview

ReplicaSets ensure that a specified number of pod replicas are running at any given time. They are the foundation for maintaining application availability and scaling in Kubernetes.

## Learning Objectives

By the end of this module, you will be able to:
- Understand what ReplicaSets are and why they're important
- Create and manage ReplicaSets
- Use labels and selectors to manage pods
- Scale applications using ReplicaSets
- Understand the relationship between ReplicaSets and Deployments
- Troubleshoot ReplicaSet issues

## Table of Contents

1. [What is a ReplicaSet?](#what-is-a-replicaset)
2. [ReplicaSet Components](#replicaset-components)
3. [Creating ReplicaSets](#creating-replicasets)
4. [Labels and Selectors](#labels-and-selectors)
5. [Scaling ReplicaSets](#scaling-replicasets)
6. [ReplicaSet vs Deployment](#replicaset-vs-deployment)
7. [Hands-On Labs](#hands-on-labs)

---

## What is a ReplicaSet?

### Definition

A **ReplicaSet** is a Kubernetes controller that ensures a specified number of pod replicas are running at any given time. If a pod crashes or is deleted, the ReplicaSet automatically creates a new pod to replace it.

### Why Use ReplicaSets?

**High Availability:**
- Ensures your application is always running
- Automatically replaces failed pods
- Maintains desired number of replicas

**Load Distribution:**
- Multiple replicas can handle more traffic
- Requests are distributed across pods
- Better resource utilization

**Self-Healing:**
- Detects pod failures automatically
- Creates replacement pods
- No manual intervention needed

### How ReplicaSets Work

```
Desired State: 3 replicas
Current State: 2 replicas

ReplicaSet Controller:
1. Detects difference (3 desired - 2 current = 1 missing)
2. Creates 1 new pod
3. Monitors until current state matches desired state
```

**Example Scenario:**
```
Time 0: ReplicaSet creates 3 pods
Time 1: Pod #2 crashes
Time 2: ReplicaSet detects only 2 pods running
Time 3: ReplicaSet creates new pod to replace #2
Time 4: 3 pods running again (desired state restored)
```

---

## ReplicaSet Components

A ReplicaSet has three essential components:

### 1. Replicas
The number of pod copies to maintain:
```yaml
spec:
  replicas: 3
```

### 2. Selector
Identifies which pods belong to this ReplicaSet:
```yaml
spec:
  selector:
    matchLabels:
      app: nginx
      tier: frontend
```

### 3. Pod Template
Defines how to create new pods:
```yaml
spec:
  template:
    metadata:
      labels:
        app: nginx
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

### Complete ReplicaSet Structure

```
┌───────────────────────────────────┐
│         ReplicaSet                │
├───────────────────────────────────┤
│ Replicas: 3                       │
│                                   │
│ Selector: app=nginx               │
│                                   │
│ Pod Template:                     │
│   - Container: nginx              │
│   - Labels: app=nginx             │
└───────────────────────────────────┘
          │
          ├──── Creates ────┐
          │                 │
     ┌────▼────┐      ┌────▼────┐      ┌─────────┐
     │  Pod 1  │      │  Pod 2  │      │  Pod 3  │
     │ (nginx) │      │ (nginx) │      │ (nginx) │
     └─────────┘      └─────────┘      └─────────┘
```

---

## Creating ReplicaSets

### Method 1: Using kubectl (Imperative)

You can create a ReplicaSet imperatively, but YAML is preferred:

```bash
# Not commonly used - better to use YAML
kubectl create -f replicaset.yaml
```

### Method 2: Using YAML Manifest (Declarative) - Recommended

**Basic ReplicaSet Example:**

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx
spec:
  # Number of pod replicas
  replicas: 3
  
  # Selector to identify pods
  selector:
    matchLabels:
      app: nginx
      
  # Template for creating pods
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

**Create the ReplicaSet:**
```bash
kubectl apply -f replicaset.yaml
```

**Verify ReplicaSet:**
```bash
# View ReplicaSets
kubectl get replicasets
# or short form
kubectl get rs

# Output:
# NAME               DESIRED   CURRENT   READY   AGE
# nginx-replicaset   3         3         3       30s
```

**View the Pods:**
```bash
kubectl get pods

# Output:
# NAME                     READY   STATUS    RESTARTS   AGE
# nginx-replicaset-abcd1   1/1     Running   0          1m
# nginx-replicaset-abcd2   1/1     Running   0          1m
# nginx-replicaset-abcd3   1/1     Running   0          1m
```

### Understanding Pod Names

ReplicaSets automatically generate pod names:
```
<replicaset-name>-<random-string>

Example:
nginx-replicaset-7k8mn
nginx-replicaset-9xp2l
nginx-replicaset-qw4r5
```

---

## Labels and Selectors

### How Labels Work

Labels are key-value pairs attached to objects. ReplicaSets use labels to identify which pods they should manage.

**Pod Labels (in template):**
```yaml
template:
  metadata:
    labels:
      app: nginx
      environment: production
      tier: frontend
```

**ReplicaSet Selector:**
```yaml
selector:
  matchLabels:
    app: nginx
    environment: production
```

### Label Matching Rules

**Important:** The selector must match the labels in the pod template, or the ReplicaSet won't be created:

```yaml
# ✅ CORRECT - Selector matches template labels
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx  # Matches!
```

```yaml
# ❌ WRONG - Selector doesn't match template labels
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: apache  # Doesn't match!
```

### Adopting Existing Pods

If you create a ReplicaSet and pods with matching labels already exist, the ReplicaSet will adopt them:

```bash
# Create a standalone pod with label app=nginx
kubectl run nginx-manual --image=nginx --labels="app=nginx"

# Create ReplicaSet with replicas=3 and selector app=nginx
kubectl apply -f replicaset.yaml

# ReplicaSet adopts the existing pod and creates only 2 new pods
# Total: 3 pods (1 existing + 2 new)
```

---

## Scaling ReplicaSets

### Method 1: Edit YAML and Reapply

```yaml
# Change replicas in YAML file
spec:
  replicas: 5  # Changed from 3 to 5
```

```bash
kubectl apply -f replicaset.yaml
```

### Method 2: Using kubectl scale

```bash
# Scale up to 5 replicas
kubectl scale replicaset nginx-replicaset --replicas=5

# Verify
kubectl get rs nginx-replicaset
```

### Method 3: Using kubectl edit

```bash
# Opens editor to modify ReplicaSet
kubectl edit replicaset nginx-replicaset

# Change replicas value, save and exit
```

### Scaling Down

```bash
# Scale down to 2 replicas
kubectl scale replicaset nginx-replicaset --replicas=2

# Kubernetes automatically terminates excess pods
# The oldest pods are usually terminated first
```

### Viewing Scale Events

```bash
# See scaling events
kubectl describe replicaset nginx-replicaset

# Events section shows:
# Normal  SuccessfulCreate  Created pod: nginx-replicaset-xyz
# Normal  SuccessfulDelete  Deleted pod: nginx-replicaset-abc
```

---

## ReplicaSet vs Deployment

### Why Deployments Are Preferred

While ReplicaSets work well, **Deployments** are the recommended way to manage replicated applications because they provide additional features:

**ReplicaSet Only:**
- Maintains desired number of pods
- Basic scaling
- Self-healing

**Deployment = ReplicaSet + More:**
- All ReplicaSet features
- Rolling updates
- Rollback capability
- Update strategies
- Revision history

### Relationship

```
Deployment
    │
    ├── Creates and manages
    │
    ▼
ReplicaSet (version 1)
    │
    ├── Creates and manages
    │
    ▼
Pods (app version 1)

When you update Deployment:

Deployment
    │
    ├── Creates new
    │
    ▼
ReplicaSet (version 2)  ←── New version
    │
    └── Creates new pods with updated version

Old ReplicaSet (version 1) is kept for rollback
```

### When to Use ReplicaSets Directly

**Use Deployments** (recommended) for:
- Application deployments
- Services that need updates
- Production workloads

**Use ReplicaSets directly** (rare) only when:
- You need custom orchestration logic
- You're building your own controller
- Very specific use cases

---

## Hands-On Labs

### Lab 1: Create Your First ReplicaSet

**Objective:** Create and manage a basic ReplicaSet

**Steps:**

1. Create a ReplicaSet manifest (`my-first-replicaset.yaml`):
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-nginx
  template:
    metadata:
      labels:
        app: my-nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

2. Apply the manifest:
```bash
kubectl apply -f my-first-replicaset.yaml
```

3. Verify creation:
```bash
kubectl get rs my-nginx-rs
kubectl get pods -l app=my-nginx
```

4. Describe the ReplicaSet:
```bash
kubectl describe rs my-nginx-rs
```

**Expected Output:**
- ReplicaSet shows 3/3 desired and ready pods
- Three pods with names like `my-nginx-rs-xxxxx`
- All pods in Running state

### Lab 2: Test Self-Healing

**Objective:** Observe ReplicaSet self-healing in action

**Steps:**

1. List the pods:
```bash
kubectl get pods -l app=my-nginx
```

2. Delete one pod:
```bash
# Replace xxxxx with actual pod name
kubectl delete pod my-nginx-rs-xxxxx
```

3. Immediately check pods again:
```bash
kubectl get pods -l app=my-nginx -w
```

**Expected Behavior:**
- Pod enters Terminating state
- ReplicaSet immediately creates a new pod
- New pod starts in ContainerCreating state
- After a few seconds, new pod is Running
- Total count remains 3

4. Verify in events:
```bash
kubectl describe rs my-nginx-rs | grep -A 5 Events
```

### Lab 3: Scale the ReplicaSet

**Objective:** Practice scaling operations

**Steps:**

1. Scale up to 5 replicas:
```bash
kubectl scale rs my-nginx-rs --replicas=5
```

2. Watch pods being created:
```bash
kubectl get pods -l app=my-nginx -w
```

3. Scale down to 2 replicas:
```bash
kubectl scale rs my-nginx-rs --replicas=2
```

4. Observe which pods are terminated:
```bash
kubectl get pods -l app=my-nginx
```

**Question to Ponder:**
- Which pods were terminated? (Usually the youngest pods)
- How quickly did scaling happen?

### Lab 4: Label Management

**Objective:** Understand label selector behavior

**Steps:**

1. Create a ReplicaSet with 3 replicas and label `app=test-app`

2. Manually create a pod with the same label:
```bash
kubectl run manual-pod --image=nginx --labels="app=test-app"
```

3. Check the ReplicaSet:
```bash
kubectl get rs
kubectl get pods -l app=test-app
```

**Expected Behavior:**
- ReplicaSet shows 3 desired, but you see 4 pods
- ReplicaSet adopts the manual pod
- ReplicaSet terminates one pod to maintain desired count (3)

4. Change a pod's label to remove it from ReplicaSet:
```bash
kubectl label pod <pod-name> app=orphan --overwrite
kubectl get pods --show-labels
```

**Expected Behavior:**
- Pod is no longer managed by ReplicaSet
- ReplicaSet creates a new pod to replace it
- You now have 4 pods total (3 managed + 1 orphan)

### Lab 5: Update Container Image (Anti-Pattern)

**Objective:** Understand why you shouldn't update ReplicaSets directly

**Steps:**

1. Update the image in the ReplicaSet:
```bash
kubectl set image rs/my-nginx-rs nginx=nginx:1.22
```

2. Check the ReplicaSet:
```bash
kubectl describe rs my-nginx-rs
```

3. Check the pods:
```bash
kubectl get pods -l app=my-nginx -o wide
kubectl describe pod <pod-name> | grep Image:
```

**Expected Behavior:**
- ReplicaSet spec shows new image (nginx:1.22)
- But existing pods still run old image (nginx:1.21)
- Only newly created pods (if you delete old ones) will use new image

**Why This Happens:**
- ReplicaSets don't update existing pods
- They only ensure the desired number of pods exist
- For updates, use Deployments (covered in Module 6)

### Lab 6: Cleanup

Delete the ReplicaSet and all its pods:
```bash
kubectl delete rs my-nginx-rs
```

Verify deletion:
```bash
kubectl get rs
kubectl get pods -l app=my-nginx
```

---

## Common Commands Reference

### Create and View

```bash
# Create ReplicaSet
kubectl apply -f replicaset.yaml

# List ReplicaSets
kubectl get replicasets
kubectl get rs

# View specific ReplicaSet
kubectl get rs <name>

# Detailed information
kubectl describe rs <name>

# View as YAML
kubectl get rs <name> -o yaml
```

### Scale

```bash
# Scale to specific number
kubectl scale rs <name> --replicas=5

# Autoscale (requires metrics-server)
kubectl autoscale rs <name> --min=2 --max=10 --cpu-percent=80
```

### Edit

```bash
# Edit ReplicaSet
kubectl edit rs <name>

# Update image (not recommended)
kubectl set image rs/<name> <container>=<image>
```

### Delete

```bash
# Delete ReplicaSet and its pods
kubectl delete rs <name>

# Delete ReplicaSet but keep pods (orphan them)
kubectl delete rs <name> --cascade=orphan
```

### Troubleshooting

```bash
# Check events
kubectl describe rs <name>

# View logs from pods
kubectl logs -l <selector>

# Get pod details
kubectl get pods -l <selector> -o wide
```

---

## Troubleshooting Common Issues

### Issue 1: Pods Not Created

**Symptoms:**
```bash
kubectl get rs
# DESIRED   CURRENT   READY
# 3         0         0
```

**Possible Causes:**
1. Selector doesn't match template labels
2. Resource constraints (insufficient cluster resources)
3. Image pull errors

**Solutions:**
```bash
# Check events
kubectl describe rs <name>

# Verify selector matches labels
kubectl get rs <name> -o yaml | grep -A 5 selector

# Check node resources
kubectl describe nodes
```

### Issue 2: Pods Stuck in Pending

**Symptoms:**
```bash
kubectl get pods
# NAME           READY   STATUS    RESTARTS   AGE
# my-rs-xxxxx    0/1     Pending   0          2m
```

**Possible Causes:**
1. Insufficient cluster resources
2. Node selectors not matching any nodes
3. Volume mounting issues

**Solutions:**
```bash
# Check pod details
kubectl describe pod <pod-name>

# Look for events like:
# "0/1 nodes are available: 1 Insufficient memory"

# Check node resources
kubectl top nodes
```

### Issue 3: Pods in CrashLoopBackOff

**Symptoms:**
```bash
kubectl get pods
# NAME           READY   STATUS             RESTARTS   AGE
# my-rs-xxxxx    0/1     CrashLoopBackOff   5          5m
```

**Possible Causes:**
1. Application crashes immediately
2. Incorrect command or arguments
3. Missing dependencies

**Solutions:**
```bash
# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous container

# Check pod events
kubectl describe pod <pod-name>
```

### Issue 4: Selector Doesn't Match Template

**Error Message:**
```
The ReplicaSet "my-rs" is invalid: 
spec.template.metadata.labels: Invalid value: 
must match spec.selector
```

**Solution:**
Ensure selector matches template labels exactly:
```yaml
spec:
  selector:
    matchLabels:
      app: myapp      # Must match exactly
  template:
    metadata:
      labels:
        app: myapp    # Must match exactly
```

---

## Best Practices

### 1. Use Deployments Instead
```bash
# ✅ Good - Use Deployments for most use cases
kubectl create deployment my-app --image=nginx

# ❌ Avoid - Direct ReplicaSet creation (unless specific need)
kubectl create -f replicaset.yaml
```

### 2. Always Use Labels
```yaml
# ✅ Good - Meaningful labels
metadata:
  labels:
    app: frontend
    tier: web
    environment: production
    version: v1.2.0
```

### 3. Set Resource Limits
```yaml
# ✅ Good - Define resource requests and limits
spec:
  template:
    spec:
      containers:
      - name: app
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### 4. Use Descriptive Names
```yaml
# ✅ Good
name: frontend-web-rs
name: api-backend-rs

# ❌ Bad
name: rs1
name: test
```

### 5. Monitor and Alert
```bash
# Set up monitoring for:
- ReplicaSet desired vs current count
- Pod restart counts
- Resource usage
```

---

## Key Takeaways

1. **ReplicaSets ensure availability** - They maintain a specified number of pod replicas
2. **Self-healing** - Automatically replace failed pods
3. **Labels are crucial** - ReplicaSets use selectors to manage pods
4. **Use Deployments instead** - Deployments provide more features (updates, rollbacks)
5. **Scaling is easy** - Use `kubectl scale` to adjust replicas
6. **ReplicaSets don't update pods** - They only maintain count, not update existing pods

---

## Next Steps

Now that you understand ReplicaSets, you're ready for:
- **[Module 6: Deployments](06-deployments.md)** - Learn the recommended way to manage applications
- Practice with the example YAML files in `examples/replicasets/`
- Experiment with scaling and self-healing in your cluster

---

## Additional Resources

- [Kubernetes Official Docs - ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)
- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [kubectl Cheat Sheet](kubectl-cheatsheet.md)

---

**Congratulations!** You now understand ReplicaSets and how they maintain application availability in Kubernetes! 🎉
