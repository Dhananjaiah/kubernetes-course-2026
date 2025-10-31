# Module 6: Deployments

## Overview

Deployments are the most commonly used Kubernetes resource for managing stateless applications. They provide declarative updates for Pods and ReplicaSets with powerful features like rolling updates, rollbacks, and scaling.

## Learning Objectives

By the end of this module, you will be able to:
- Understand what Deployments are and why they're the preferred way to manage applications
- Create and manage Deployments
- Update applications with zero downtime using rolling updates
- Rollback to previous versions
- Scale Deployments up and down
- Monitor Deployment status and troubleshoot issues

## Table of Contents

1. [What is a Deployment?](#what-is-a-deployment)
2. [Creating Deployments](#creating-deployments)
3. [Updating Deployments](#updating-deployments)
4. [Rolling Updates](#rolling-updates)
5. [Rollback](#rollback)
6. [Scaling Deployments](#scaling-deployments)
7. [Deployment Strategies](#deployment-strategies)
8. [Hands-On Labs](#hands-on-labs)

---

## What is a Deployment?

### Definition

A **Deployment** provides declarative updates for Pods and ReplicaSets. It's the recommended way to deploy and manage stateless applications in Kubernetes.

### Why Use Deployments?

Deployments build on ReplicaSets and add critical features:

**✅ Deployments Provide:**
- Rolling updates (zero-downtime deployments)
- Rollback to previous versions
- Pause and resume updates
- Version history tracking
- Automatic ReplicaSet management
- All ReplicaSet features (scaling, self-healing)

**❌ Plain ReplicaSets Only Provide:**
- Maintaining replica count
- Basic scaling
- Self-healing

### Deployment Hierarchy

```
┌────────────────────────────┐
│       Deployment           │
│  (Manages ReplicaSets)     │
└────────────┬───────────────┘
             │
      ┌──────┴──────┐
      │             │
┌─────▼──────┐  ┌──▼──────────┐
│ ReplicaSet │  │ ReplicaSet  │
│ (version1) │  │ (version 2) │ ← New version
│  Scaling   │  │  Active     │
│  down: 0   │  │  Scaling    │
│  pods      │  │  up: 3 pods │
└────────────┘  └──┬──────────┘
                   │
        ┌──────────┼──────────┐
        │          │          │
    ┌───▼───┐  ┌──▼───┐  ┌──▼───┐
    │ Pod 1 │  │ Pod 2│  │ Pod 3│
    └───────┘  └──────┘  └──────┘
```

### Real-World Example

**Scenario:** You have a web application running version 1.0, and you want to update to version 2.0 without downtime.

**Without Deployment:**
1. Delete all pods
2. Users get errors (downtime!)
3. Create new pods with version 2.0
4. Hope everything works

**With Deployment:**
1. Update Deployment with new version
2. Kubernetes gradually replaces old pods with new ones
3. No downtime - users don't notice
4. If something breaks, rollback with one command

---

## Creating Deployments

### Method 1: Imperative (kubectl create)

```bash
# Create a deployment imperatively
kubectl create deployment nginx-deployment --image=nginx:1.21 --replicas=3

# Verify
kubectl get deployments
kubectl get pods
```

### Method 2: Declarative (YAML) - Recommended

**Basic Deployment Example:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  # Number of pod replicas
  replicas: 3
  
  # Selector to match pods
  selector:
    matchLabels:
      app: nginx
      
  # Pod template
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

**Apply the Deployment:**
```bash
kubectl apply -f deployment.yaml
```

### Viewing Deployments

```bash
# List all deployments
kubectl get deployments
# or short form
kubectl get deploy

# Output:
# NAME               READY   UP-TO-DATE   AVAILABLE   AGE
# nginx-deployment   3/3     3            3           2m

# Detailed information
kubectl describe deployment nginx-deployment

# View as YAML
kubectl get deployment nginx-deployment -o yaml
```

### Understanding Deployment Status

```bash
kubectl get deployment nginx-deployment
```

**Output columns explained:**
- **READY**: Number of ready pods / desired pods (e.g., 3/3)
- **UP-TO-DATE**: Number of pods updated to latest version
- **AVAILABLE**: Number of pods available to users
- **AGE**: Time since deployment was created

---

## Updating Deployments

### Update Methods

#### Method 1: Edit YAML and Reapply

```yaml
# Change image version in deployment.yaml
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.22  # Changed from 1.21
```

```bash
kubectl apply -f deployment.yaml
```

#### Method 2: Using kubectl set image

```bash
# Update image
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Verify update
kubectl rollout status deployment/nginx-deployment
```

#### Method 3: Using kubectl edit

```bash
# Opens editor to modify deployment
kubectl edit deployment nginx-deployment

# Change image version, save and exit
```

### Monitoring the Update

```bash
# Watch rollout status
kubectl rollout status deployment/nginx-deployment

# Output:
# Waiting for deployment "nginx-deployment" rollout to finish: 1 out of 3 new replicas have been updated...
# Waiting for deployment "nginx-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
# deployment "nginx-deployment" successfully rolled out

# Watch pods in real-time
kubectl get pods -w

# Check rollout history
kubectl rollout history deployment/nginx-deployment
```

---

## Rolling Updates

### How Rolling Updates Work

Rolling updates gradually replace pods with new versions:

**Process:**
1. Create new ReplicaSet for new version
2. Scale up new ReplicaSet (create 1 new pod)
3. Wait for new pod to be ready
4. Scale down old ReplicaSet (delete 1 old pod)
5. Repeat steps 2-4 until all pods are updated

**Visual Example:**

```
Time 0: All pods running version 1.0
┌──────┐  ┌──────┐  ┌──────┐
│ v1.0 │  │ v1.0 │  │ v1.0 │
└──────┘  └──────┘  └──────┘

Time 1: Start creating v2.0 pod
┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐
│ v1.0 │  │ v1.0 │  │ v1.0 │  │ v2.0 │ ← Creating
└──────┘  └──────┘  └──────┘  └──────┘

Time 2: v2.0 ready, terminate one v1.0
┌──────┐  ┌──────┐  ┌──────┐
│ v1.0 │  │ v1.0 │  │ v2.0 │
└──────┘  └──────┘  └──────┘

Time 3: Create another v2.0
┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐
│ v1.0 │  │ v1.0 │  │ v2.0 │  │ v2.0 │ ← Creating
└──────┘  └──────┘  └──────┘  └──────┘

Time 4: Terminate another v1.0
┌──────┐  ┌──────┐  ┌──────┐
│ v1.0 │  │ v2.0 │  │ v2.0 │
└──────┘  └──────┘  └──────┘

Time 5: Final update
┌──────┐  ┌──────┐  ┌──────┐
│ v2.0 │  │ v2.0 │  │ v2.0 │  ← All updated!
└──────┘  └──────┘  └──────┘
```

### Configuring Rolling Updates

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 10
  
  # Rolling update strategy
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2        # Max extra pods during update
      maxUnavailable: 1  # Max unavailable pods during update
  
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

**Parameters Explained:**

- **maxSurge**: Maximum number of extra pods that can exist during update
  - `maxSurge: 2` means: Can have up to 12 pods (10 + 2) during rollout
  - Can be number (2) or percentage (25%)

- **maxUnavailable**: Maximum pods that can be unavailable during update
  - `maxUnavailable: 1` means: At least 9 pods (10 - 1) must be available
  - Can be number (1) or percentage (10%)

**Examples:**

```yaml
# Fast rollout - more aggressive
strategy:
  rollingUpdate:
    maxSurge: 50%
    maxUnavailable: 25%

# Conservative rollout - minimal impact
strategy:
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0  # Zero downtime guaranteed
```

### Pausing and Resuming Updates

```bash
# Pause rollout (useful for testing)
kubectl rollout pause deployment/nginx-deployment

# Make changes
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# Changes queued but not applied yet

# Resume rollout
kubectl rollout resume deployment/nginx-deployment
```

---

## Rollback

### Why Rollback?

Rollbacks are essential when:
- New version has bugs
- Application crashes
- Performance degrades
- Features don't work as expected

### How Rollback Works

Deployments maintain revision history. Each update creates a new ReplicaSet that's kept for rollback purposes.

```
Deployment Revisions:
┌────────────────┐
│ Revision 3     │ ← Current (has bug)
│ (nginx:1.23)   │
├────────────────┤
│ Revision 2     │
│ (nginx:1.22)   │
├────────────────┤
│ Revision 1     │
│ (nginx:1.21)   │
└────────────────┘
```

### View Rollout History

```bash
# View all revisions
kubectl rollout history deployment/nginx-deployment

# Output:
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         kubectl set image deployment/nginx-deployment nginx=nginx:1.22
# 3         kubectl set image deployment/nginx-deployment nginx=nginx:1.23

# View specific revision details
kubectl rollout history deployment/nginx-deployment --revision=2
```

### Rollback to Previous Version

```bash
# Rollback to previous revision
kubectl rollout undo deployment/nginx-deployment

# Verify rollback
kubectl rollout status deployment/nginx-deployment
kubectl get pods
```

### Rollback to Specific Revision

```bash
# Rollback to specific revision (e.g., revision 1)
kubectl rollout undo deployment/nginx-deployment --to-revision=1

# Verify
kubectl describe deployment nginx-deployment | grep Image
```

### Recording Change Cause

To track why changes were made, use annotations:

```bash
# Update with change-cause annotation
kubectl set image deployment/nginx-deployment nginx=nginx:1.22 \
  --record

# Or annotate manually
kubectl annotate deployment/nginx-deployment \
  kubernetes.io/change-cause="Updated to nginx 1.22 for bug fix"

# View in history
kubectl rollout history deployment/nginx-deployment
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         Updated to nginx 1.22 for bug fix
```

### Revision Limit

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  # Keep last 10 revisions for rollback
  revisionHistoryLimit: 10
  
  replicas: 3
  # ... rest of spec
```

---

## Scaling Deployments

### Manual Scaling

```bash
# Scale up to 5 replicas
kubectl scale deployment nginx-deployment --replicas=5

# Scale down to 2 replicas
kubectl scale deployment nginx-deployment --replicas=2

# Verify
kubectl get deployment nginx-deployment
```

### Scaling in YAML

```yaml
spec:
  replicas: 5  # Change this value
```

```bash
kubectl apply -f deployment.yaml
```

### Auto-scaling (HPA)

Horizontal Pod Autoscaler automatically scales based on CPU/memory:

```bash
# Create HPA (requires metrics-server)
kubectl autoscale deployment nginx-deployment \
  --min=2 \
  --max=10 \
  --cpu-percent=80

# View HPA
kubectl get hpa
```

**HPA in YAML:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

---

## Deployment Strategies

### 1. Rolling Update (Default)

**Best for:** Most applications, zero-downtime updates

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

**Pros:**
- Zero downtime
- Gradual rollout
- Easy rollback

**Cons:**
- Both versions run simultaneously (briefly)
- Slower than Recreate

### 2. Recreate

**Best for:** Applications that can't run multiple versions simultaneously

```yaml
strategy:
  type: Recreate
```

**Pros:**
- Simple
- Only one version runs at a time
- Fast switch between versions

**Cons:**
- Downtime during update
- No gradual rollout

**Process:**
1. Delete all old pods
2. Wait for all to terminate
3. Create new pods

---

## Hands-On Labs

### Lab 1: Create Your First Deployment

**Objective:** Create and verify a basic Deployment

**Steps:**

1. Create deployment manifest (`my-first-deployment.yaml`):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: webapp
        image: nginx:1.21
        ports:
        - containerPort: 80
```

2. Apply the deployment:
```bash
kubectl apply -f my-first-deployment.yaml
```

3. Verify creation:
```bash
kubectl get deployments
kubectl get replicasets
kubectl get pods
```

4. Observe the hierarchy:
```bash
# Deployment manages ReplicaSet
kubectl describe deployment webapp-deployment

# ReplicaSet manages Pods
kubectl get rs
```

**Expected Output:**
- 1 Deployment created
- 1 ReplicaSet created (with generated name)
- 3 Pods running

### Lab 2: Rolling Update

**Objective:** Perform a rolling update with zero downtime

**Steps:**

1. Update to nginx 1.22:
```bash
kubectl set image deployment/webapp-deployment webapp=nginx:1.22
```

2. Watch the rollout in real-time:
```bash
# Terminal 1: Watch rollout status
kubectl rollout status deployment/webapp-deployment

# Terminal 2: Watch pods
kubectl get pods -w
```

3. Observe what happens:
- Old pods gradually terminate
- New pods are created
- At no point are all pods down

4. Verify the update:
```bash
kubectl describe deployment webapp-deployment | grep Image
# Should show nginx:1.22
```

5. Check ReplicaSets:
```bash
kubectl get rs
```

**Expected Behavior:**
- 2 ReplicaSets exist
- Old ReplicaSet has 0 pods
- New ReplicaSet has 3 pods

### Lab 3: Rollback

**Objective:** Rollback to a previous version

**Steps:**

1. Check current version:
```bash
kubectl describe deployment webapp-deployment | grep Image
# Shows nginx:1.22
```

2. View rollout history:
```bash
kubectl rollout history deployment/webapp-deployment
```

3. Rollback to previous version:
```bash
kubectl rollout undo deployment/webapp-deployment
```

4. Watch the rollback:
```bash
kubectl rollout status deployment/webapp-deployment
```

5. Verify rollback:
```bash
kubectl describe deployment webapp-deployment | grep Image
# Should show nginx:1.21 (back to original)
```

### Lab 4: Scaling

**Objective:** Practice scaling operations

**Steps:**

1. Current state:
```bash
kubectl get deployment webapp-deployment
# Shows 3 replicas
```

2. Scale up:
```bash
kubectl scale deployment webapp-deployment --replicas=6
```

3. Watch pods being created:
```bash
kubectl get pods -w
```

4. Scale down:
```bash
kubectl scale deployment webapp-deployment --replicas=2
```

5. Observe which pods are terminated

### Lab 5: Update Strategy Configuration

**Objective:** Configure rolling update behavior

**Steps:**

1. Create deployment with custom strategy:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: strategic-deployment
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 3
      maxUnavailable: 2
  selector:
    matchLabels:
      app: strategic
  template:
    metadata:
      labels:
        app: strategic
    spec:
      containers:
      - name: app
        image: nginx:1.21
```

2. Apply and update:
```bash
kubectl apply -f strategic-deployment.yaml
kubectl set image deployment/strategic-deployment app=nginx:1.22
```

3. Watch the rollout:
```bash
kubectl get pods -w
```

**Observe:**
- Maximum 13 pods at any time (10 + maxSurge 3)
- Minimum 8 pods available (10 - maxUnavailable 2)

### Lab 6: Test Recreate Strategy

**Objective:** Understand Recreate strategy

**Steps:**

1. Create deployment with Recreate strategy:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: recreate-deployment
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: recreate-app
  template:
    metadata:
      labels:
        app: recreate-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
```

2. Apply:
```bash
kubectl apply -f recreate-deployment.yaml
```

3. Update image:
```bash
kubectl set image deployment/recreate-deployment app=nginx:1.22
```

4. Watch pods:
```bash
kubectl get pods -w
```

**Observe:**
- All old pods terminate first
- Brief period with 0 pods (downtime!)
- Then all new pods are created

### Lab 7: Cleanup

```bash
# Delete deployments
kubectl delete deployment webapp-deployment
kubectl delete deployment strategic-deployment
kubectl delete deployment recreate-deployment

# Verify everything is deleted
kubectl get deployments
kubectl get pods
```

---

## Common Commands Reference

### Create and View

```bash
# Create deployment
kubectl create deployment <name> --image=<image>
kubectl apply -f deployment.yaml

# List deployments
kubectl get deployments
kubectl get deploy

# Detailed info
kubectl describe deployment <name>

# View as YAML
kubectl get deployment <name> -o yaml
```

### Update

```bash
# Update image
kubectl set image deployment/<name> <container>=<image>

# Edit deployment
kubectl edit deployment <name>

# Patch deployment
kubectl patch deployment <name> -p '{"spec":{"replicas":5}}'
```

### Rollout Management

```bash
# Check rollout status
kubectl rollout status deployment/<name>

# View history
kubectl rollout history deployment/<name>

# Pause rollout
kubectl rollout pause deployment/<name>

# Resume rollout
kubectl rollout resume deployment/<name>

# Rollback
kubectl rollout undo deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=2
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment <name> --replicas=5

# Autoscaling
kubectl autoscale deployment <name> --min=2 --max=10 --cpu-percent=80

# View autoscaler
kubectl get hpa
```

### Delete

```bash
# Delete deployment
kubectl delete deployment <name>

# Delete deployment but keep pods
kubectl delete deployment <name> --cascade=orphan
```

---

## Troubleshooting Common Issues

### Issue 1: Rollout Stuck

**Symptoms:**
```bash
kubectl rollout status deployment/my-app
# Waiting for deployment "my-app" rollout to finish: 1 out of 3 new replicas have been updated...
# (Stuck for minutes)
```

**Possible Causes:**
1. Image pull errors
2. Insufficient resources
3. Health check failures
4. Application crashes

**Solutions:**
```bash
# Check pod status
kubectl get pods

# Check events
kubectl describe deployment my-app

# Check pod logs
kubectl logs <pod-name>

# Check previous pod logs if crashing
kubectl logs <pod-name> --previous
```

### Issue 2: Failed Rollback

**Symptoms:**
```bash
kubectl rollout undo deployment/my-app
# Error: no previous revision available
```

**Cause:**
- No previous revisions saved
- revisionHistoryLimit set to 0

**Solution:**
```bash
# Check revision history
kubectl rollout history deployment/my-app

# Ensure revisionHistoryLimit > 0
kubectl edit deployment my-app
# Set spec.revisionHistoryLimit: 10
```

### Issue 3: Pods Not Updating

**Symptoms:**
- Changed deployment spec
- Old pods still running

**Cause:**
- Only changed non-pod spec fields (e.g., replicas, labels on deployment)
- Pod template didn't change

**Solution:**
```bash
# Force new rollout by changing pod template
kubectl patch deployment my-app -p \
  '{"spec":{"template":{"metadata":{"annotations":{"update":"'$(date +%s)'"}}}}'
```

### Issue 4: ImagePullBackOff

**Symptoms:**
```bash
kubectl get pods
# NAME                   READY   STATUS             RESTARTS   AGE
# my-app-xxx-yyy         0/1     ImagePullBackOff   0          2m
```

**Possible Causes:**
1. Image doesn't exist
2. Wrong image name/tag
3. Private registry authentication

**Solutions:**
```bash
# Check image name
kubectl describe pod <pod-name> | grep Image

# Check events
kubectl describe pod <pod-name> | grep -A 10 Events

# Test image manually
docker pull <image-name>
```

---

## Best Practices

### 1. Always Use Deployments for Stateless Apps

```bash
# ✅ Good
kubectl create deployment my-app --image=nginx

# ❌ Avoid - Direct pod/replicaset creation
kubectl run my-app --image=nginx
```

### 2. Set Resource Requests and Limits

```yaml
# ✅ Good
spec:
  template:
    spec:
      containers:
      - name: app
        resources:
          requests:
            memory: "128Mi"
            cpu: "250m"
          limits:
            memory: "256Mi"
            cpu: "500m"
```

### 3. Use Health Checks

```yaml
# ✅ Good - Will be covered in Module 13
spec:
  template:
    spec:
      containers:
      - name: app
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
```

### 4. Configure Rolling Update Strategy

```yaml
# ✅ Good - Zero downtime
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### 5. Keep Revision History

```yaml
# ✅ Good - Allows rollback
spec:
  revisionHistoryLimit: 10
```

### 6. Use Labels and Selectors Properly

```yaml
# ✅ Good - Meaningful labels
metadata:
  labels:
    app: frontend
    version: v1.0.0
    tier: web
```

### 7. Record Change Causes

```bash
# ✅ Good
kubectl set image deployment/my-app app=nginx:1.22 --record

# Or annotate
kubectl annotate deployment/my-app \
  kubernetes.io/change-cause="Fixed security vulnerability"
```

---

## Key Takeaways

1. **Deployments are the standard** - Use them for all stateless applications
2. **Rolling updates enable zero downtime** - Gradual replacement of pods
3. **Rollback is easy** - One command to revert to previous version
4. **Deployments manage ReplicaSets** - You usually don't interact with ReplicaSets directly
5. **Scaling is flexible** - Manual or automatic with HPA
6. **Strategy matters** - Choose RollingUpdate or Recreate based on your needs
7. **Health checks are critical** - Ensure proper readiness checks (covered in Module 13)

---

## Next Steps

Now that you understand Deployments, you're ready for:
- **[Module 7: Labels & Selectors](07-labels-selectors.md)** - Organize and select resources
- **[Module 8: Services](08-services.md)** - Expose your deployments to network traffic
- **[Module 9: Update Strategies & Rollback](09-update-strategies.md)** - Advanced deployment patterns
- Practice with the example YAML files in `examples/deployments/`

---

## Additional Resources

- [Kubernetes Official Docs - Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Rolling Updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
- [kubectl Cheat Sheet](kubectl-cheatsheet.md)

---

**Congratulations!** You now know how to deploy, update, and manage applications in Kubernetes! 🎉
