# Module 3: Pods & Pod Lifecycle

## Overview

Pods are the smallest deployable units in Kubernetes. This module covers what pods are, how they work, their lifecycle, and how to manage them effectively.

## Learning Objectives

By the end of this module, you will be able to:
- Understand what a Pod is and why it's important
- Create and manage Pods using kubectl and YAML manifests
- Understand Pod lifecycle phases
- Work with multi-container Pods
- Troubleshoot common Pod issues including CrashLoopBackOff
- Use container restart policies effectively

## Table of Contents

1. [What is a Pod?](#what-is-a-pod)
2. [Pod Lifecycle](#pod-lifecycle)
3. [Container Restart Policies](#container-restart-policies)
4. [Creating Pods](#creating-pods)
5. [Multi-Container Pods](#multi-container-pods)
6. [Troubleshooting Pods](#troubleshooting-pods)
7. [Pod Management Commands](#pod-management-commands)

---

## What is a Pod?

### Definition

A **Pod** is the smallest deployable unit in Kubernetes. It represents a single instance of a running process in your cluster.

### Key Characteristics

- **Single IP Address**: All containers in a Pod share the same network namespace (IP address and ports)
- **Shared Storage**: Containers can share volumes
- **Co-located**: Containers run on the same node
- **Ephemeral**: Pods are disposable and replaceable
- **Atomic Unit**: Pod is created, scheduled, and terminated as a single unit

### Pod Structure

```
┌─────────────────────────────────────────┐
│              Pod (10.244.1.5)           │
│                                         │
│  ┌─────────────┐    ┌─────────────┐   │
│  │ Container 1 │    │ Container 2 │   │
│  │   (nginx)   │    │  (sidecar)  │   │
│  └─────────────┘    └─────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │       Shared Volumes            │  │
│  └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Why Pods? (Why Not Just Containers?)

Kubernetes uses Pods as an abstraction because:

1. **Co-location**: Some containers need to run together (e.g., app + logging agent)
2. **Shared Resources**: Containers in a Pod can easily share data via volumes
3. **Network Simplicity**: localhost communication between containers
4. **Atomic Scheduling**: All containers are scheduled together on the same node

### Common Patterns

**Single Container Pod (Most Common):**
```
One Pod = One Container
Used for most applications
```

**Multi-Container Pod:**
```
One Pod = Multiple Containers
Used for tightly coupled services
Examples: sidecar, ambassador, adapter patterns
```

---

## Pod Lifecycle

### Lifecycle Phases

A Pod goes through several phases during its lifetime:

```
┌──────────┐     ┌─────────┐     ┌─────────┐
│ Pending  │────▶│ Running │────▶│Succeeded│
└──────────┘     └─────────┘     └─────────┘
                      │
                      ▼
                 ┌─────────┐     ┌─────────┐
                 │ Failed  │     │ Unknown │
                 └─────────┘     └─────────┘
```

| Phase | Description | What's Happening |
|-------|-------------|------------------|
| **Pending** | Pod accepted but not running yet | - Scheduled to a node<br>- Downloading images<br>- Waiting for resources |
| **Running** | Pod bound to node, containers running | - At least one container is running<br>- Or starting or restarting |
| **Succeeded** | All containers terminated successfully | - Exit code 0<br>- Won't be restarted |
| **Failed** | All containers terminated, at least one failed | - Non-zero exit code<br>- Or terminated by system |
| **Unknown** | Pod state cannot be determined | - Communication problem with node<br>- Node may be down |

### Phase Transitions

**Normal Flow:**
```
1. kubectl create -f pod.yaml
        ↓
2. Pod: Pending (being scheduled)
        ↓
3. Kubelet pulls image
        ↓
4. Pod: Running (containers started)
        ↓
5. Application runs successfully
        ↓
6. Pod: Succeeded (for jobs) OR keeps Running (for services)
```

**Failure Scenario:**
```
1. Pod: Running
        ↓
2. Container crashes
        ↓
3. Restart policy determines next action:
   - Always: Restart container → Running
   - OnFailure: Restart if exit code != 0
   - Never: Pod → Failed
```

### Container States

Within a running Pod, each container has a state:

| State | Description |
|-------|-------------|
| **Waiting** | Container is not running yet (pulling image, waiting for dependencies) |
| **Running** | Container is executing without issues |
| **Terminated** | Container finished execution or failed |

---

## Container Restart Policies

Restart policies control what happens when a container exits.

### Available Policies

```yaml
restartPolicy: Always      # Default
restartPolicy: OnFailure   # Only restart on failure
restartPolicy: Never       # Don't restart
```

### Restart Policy Behavior

| Exit Code | Always | OnFailure | Never |
|-----------|--------|-----------|-------|
| **0 (Success)** | Restart | Don't restart | Don't restart |
| **Non-zero (Failure)** | Restart | Restart | Don't restart |

### When to Use Each Policy

**Always (Default)**
- Long-running services (web servers, APIs)
- Pods that should always be available
- Most Deployments use this

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
spec:
  restartPolicy: Always
  containers:
  - name: nginx
    image: nginx
```

**OnFailure**
- Batch jobs that should retry on failure
- Data processing tasks
- Jobs that may fail temporarily

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-processor
spec:
  restartPolicy: OnFailure
  containers:
  - name: processor
    image: data-processor:v1
```

**Never**
- One-time tasks
- Jobs that shouldn't retry
- Debugging scenarios

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: one-time-task
spec:
  restartPolicy: Never
  containers:
  - name: task
    image: task-runner:v1
```

---

## Creating Pods

### Imperative Approach (kubectl run)

Quick way to create Pods for testing:

```bash
# Create a simple Pod
kubectl run nginx --image=nginx

# Create Pod with port exposed
kubectl run nginx --image=nginx --port=80

# Create Pod with environment variable
kubectl run nginx --image=nginx --env="ENV=production"

# Create Pod and execute command
kubectl run busybox --image=busybox --command -- sleep 3600

# Create Pod in specific namespace
kubectl run nginx --image=nginx -n development

# Dry run (see YAML without creating)
kubectl run nginx --image=nginx --dry-run=client -o yaml
```

### Declarative Approach (YAML Manifests)

Recommended for production use:

**Basic Pod Definition:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: production
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
```

**Pod with Resource Limits:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

**Pod with Environment Variables:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:v1
    env:
    - name: DATABASE_URL
      value: "postgres://db:5432/mydb"
    - name: ENVIRONMENT
      value: "production"
    - name: LOG_LEVEL
      value: "info"
```

**Creating from YAML:**
```bash
# Create Pod
kubectl apply -f pod.yaml

# Create with multiple files
kubectl apply -f pod1.yaml -f pod2.yaml

# Create from directory
kubectl apply -f ./manifests/

# Create from URL
kubectl apply -f https://example.com/pod.yaml
```

---

## Multi-Container Pods

### When to Use Multi-Container Pods

Use multi-container Pods when containers are:
- **Tightly coupled**: Must run together
- **Share resources**: Need to access same data
- **Life-cycle dependent**: Started and stopped together

### Common Patterns

#### 1. Sidecar Pattern

Helper container that enhances the main container.

**Example: Logging Sidecar**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-sidecar
spec:
  containers:
  # Main application container
  - name: app
    image: myapp:v1
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
  
  # Sidecar container for log shipping
  - name: log-shipper
    image: fluent/fluentd:v1.14
    volumeMounts:
    - name: logs
      mountPath: /var/log/app
      readOnly: true
  
  volumes:
  - name: logs
    emptyDir: {}
```

#### 2. Ambassador Pattern

Proxy container that handles network communication.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-ambassador
spec:
  containers:
  # Main application
  - name: app
    image: myapp:v1
  
  # Ambassador proxy
  - name: proxy
    image: envoy:v1.20
    ports:
    - containerPort: 8080
```

#### 3. Adapter Pattern

Container that transforms output to standard format.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-adapter
spec:
  containers:
  # Application with custom metrics format
  - name: app
    image: myapp:v1
  
  # Adapter converts metrics to Prometheus format
  - name: metrics-adapter
    image: metrics-adapter:v1
    ports:
    - containerPort: 9090
```

---

## Troubleshooting Pods

### Common Issues

#### CrashLoopBackOff

**What it means:** Container starts, crashes, Kubernetes tries to restart, crashes again.

**Causes:**
- Application error on startup
- Missing dependencies
- Configuration error
- Resource limits too low

**Debugging:**
```bash
# View pod status
kubectl get pod <pod-name>

# Check pod events
kubectl describe pod <pod-name>

# View container logs
kubectl logs <pod-name>

# View previous container logs (after crash)
kubectl logs <pod-name> --previous

# Check resource usage
kubectl top pod <pod-name>
```

**Exponential Backoff:**
When a Pod crashes repeatedly, Kubernetes uses exponential backoff:
```
Restart 1: wait 0s
Restart 2: wait 10s
Restart 3: wait 20s
Restart 4: wait 40s
Restart 5: wait 80s
Max delay: 5 minutes
```

#### ImagePullBackOff

**What it means:** Cannot pull container image.

**Causes:**
- Image doesn't exist
- Wrong image name or tag
- Private registry without credentials
- Network issues

**Debug:**
```bash
kubectl describe pod <pod-name>
# Look for "Failed to pull image" in events
```

**Solution:**
```yaml
# For private registry, add imagePullSecrets
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod
spec:
  imagePullSecrets:
  - name: registry-credentials
  containers:
  - name: app
    image: private.registry.com/myapp:v1
```

#### Pending State

**What it means:** Pod cannot be scheduled to a node.

**Causes:**
- Insufficient resources (CPU/memory)
- No nodes match node selector
- Taints prevent scheduling
- Volume mounting issues

**Debug:**
```bash
kubectl describe pod <pod-name>
# Look at Events section for scheduling errors

kubectl get nodes
# Check available resources
```

---

## Pod Management Commands

### Viewing Pods

```bash
# List pods in current namespace
kubectl get pods

# List pods in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces

# List pods with more details
kubectl get pods -o wide

# List pods with labels
kubectl get pods --show-labels

# Filter by label
kubectl get pods -l app=nginx
kubectl get pods -l environment=production,tier=frontend

# Watch pods in real-time
kubectl get pods --watch
kubectl get pods -w
```

### Pod Details

```bash
# Describe pod (shows events, conditions, etc.)
kubectl describe pod <pod-name>

# Get pod YAML
kubectl get pod <pod-name> -o yaml

# Get pod JSON
kubectl get pod <pod-name> -o json

# Get specific field
kubectl get pod <pod-name> -o jsonpath='{.status.podIP}'
```

### Logs

```bash
# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Logs from specific container in multi-container pod
kubectl logs <pod-name> -c <container-name>

# Previous container logs (after crash)
kubectl logs <pod-name> --previous

# Last N lines
kubectl logs <pod-name> --tail=50

# Logs since time
kubectl logs <pod-name> --since=1h
```

### Executing Commands

```bash
# Execute command in pod
kubectl exec <pod-name> -- ls /app

# Interactive shell
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- /bin/sh

# Execute in specific container
kubectl exec -it <pod-name> -c <container-name> -- bash

# Run commands
kubectl exec <pod-name> -- env
kubectl exec <pod-name> -- ps aux
kubectl exec <pod-name> -- curl localhost:8080
```

### Deleting Pods

```bash
# Delete pod
kubectl delete pod <pod-name>

# Delete immediately (no grace period)
kubectl delete pod <pod-name> --grace-period=0 --force

# Delete all pods in namespace
kubectl delete pods --all

# Delete pods by label
kubectl delete pods -l app=nginx

# Delete from file
kubectl delete -f pod.yaml
```

---

## Hands-On Lab

### Lab 1: Create and Manage Pods

```bash
# 1. Create a simple Pod
kubectl run nginx --image=nginx

# 2. Check status
kubectl get pods
kubectl get pods -o wide

# 3. Describe the Pod
kubectl describe pod nginx

# 4. View logs
kubectl logs nginx

# 5. Execute command in Pod
kubectl exec nginx -- nginx -v

# 6. Get interactive shell
kubectl exec -it nginx -- bash
# Inside container:
ls /usr/share/nginx/html
cat /etc/nginx/nginx.conf
exit

# 7. Delete Pod
kubectl delete pod nginx
```

### Lab 2: Working with YAML Manifests

```bash
# 1. Generate Pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-pod.yaml

# 2. Edit the YAML to add labels
cat >> nginx-pod.yaml << 'EOF'
metadata:
  labels:
    app: web
    tier: frontend
EOF

# 3. Create Pod from YAML
kubectl apply -f nginx-pod.yaml

# 4. Verify Pod with labels
kubectl get pods --show-labels

# 5. Filter by label
kubectl get pods -l app=web

# 6. Clean up
kubectl delete -f nginx-pod.yaml
```

### Lab 3: Multi-Container Pod

```bash
# Create multi-container Pod
cat > multi-container-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: multi-container
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'while true; do date; sleep 5; done']
EOF

# Apply
kubectl apply -f multi-container-pod.yaml

# Check both containers are running
kubectl get pod multi-container

# View logs from specific container
kubectl logs multi-container -c nginx
kubectl logs multi-container -c busybox

# Exec into specific container
kubectl exec -it multi-container -c nginx -- bash

# Clean up
kubectl delete -f multi-container-pod.yaml
```

---

## Summary

In this module, you learned:
- ✅ Pods are the smallest deployable units in Kubernetes
- ✅ Pod lifecycle phases and state transitions
- ✅ Container restart policies and when to use them
- ✅ How to create Pods using kubectl and YAML
- ✅ Multi-container Pod patterns (sidecar, ambassador, adapter)
- ✅ Common troubleshooting techniques
- ✅ Essential Pod management commands

### Key Takeaways

1. **Pods are ephemeral**: Treat them as disposable
2. **Restart policies matter**: Choose based on your workload type
3. **Use YAML for production**: Imperative commands are for testing
4. **Multi-container Pods**: Only for tightly coupled services
5. **Check logs and events**: First step in troubleshooting

## Next Steps

You now understand Pods! Next, learn about [Module 4: Namespaces](04-namespaces.md) to organize your cluster resources effectively.

## Additional Resources

- [Pod Overview](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Configure Pods](https://kubernetes.io/docs/tasks/configure-pod-container/)

---

[← Previous: Kubernetes Architecture](02-kubernetes-architecture.md) | [Next: Namespaces →](04-namespaces.md)
