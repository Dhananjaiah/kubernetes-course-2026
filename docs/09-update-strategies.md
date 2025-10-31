# Module 9: Update Strategies & Rollback

## Overview

This module covers advanced deployment strategies for updating applications with zero downtime, performing safe rollbacks, and implementing various deployment patterns like blue-green and canary deployments.

## Learning Objectives

By the end of this module, you will be able to:
- Implement rolling updates with custom configurations
- Perform safe rollbacks to previous versions
- Use deployment strategies for zero-downtime updates
- Implement blue-green deployments
- Implement canary deployments
- Monitor and troubleshoot deployment updates

## Table of Contents

1. [Rolling Update Strategy](#rolling-update-strategy)
2. [Recreate Strategy](#recreate-strategy)
3. [Blue-Green Deployments](#blue-green-deployments)
4. [Canary Deployments](#canary-deployments)
5. [Rollback Strategies](#rollback-strategies)
6. [Hands-On Labs](#hands-on-labs)

---

## Rolling Update Strategy

### Overview

Rolling updates gradually replace old pods with new ones, ensuring no downtime.

### Configuration Parameters

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-app
spec:
  replicas: 10
  
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 3          # Max extra pods during update (default 25%)
      maxUnavailable: 2    # Max unavailable pods (default 25%)
      
  # Minimum seconds pod must be ready before considered available
  minReadySeconds: 10
  
  # Seconds deployment waits for pod to become ready
  progressDeadlineSeconds: 600
  
  selector:
    matchLabels:
      app: rolling-app
  template:
    metadata:
      labels:
        app: rolling-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### maxSurge and maxUnavailable

**maxSurge:**
- Number or percentage of pods that can exist above desired count
- `maxSurge: 3` with 10 replicas = max 13 pods during update
- Higher value = faster rollout, more resources

**maxUnavailable:**
- Number or percentage that can be unavailable during update
- `maxUnavailable: 2` with 10 replicas = min 8 pods available
- Lower value = safer but slower rollout

### Update Flow Example

```
Replicas: 10, maxSurge: 2, maxUnavailable: 1

Step 1: Create 2 new pods (10 old + 2 new = 12 total)
Step 2: Wait for new pods to be ready
Step 3: Terminate 1 old pod (11 total, 9 old + 2 new)
Step 4: Create 2 more new pods (13 total, 9 old + 4 new)
Step 5: Terminate 1 old pod (12 total, 8 old + 4 new)
...continue until all pods updated
```

### Performing Rolling Update

```bash
# Method 1: Update image
kubectl set image deployment/rolling-app app=nginx:1.22

# Method 2: Edit deployment
kubectl edit deployment rolling-app

# Method 3: Apply updated YAML
kubectl apply -f deployment.yaml

# Monitor rollout
kubectl rollout status deployment/rolling-app

# Watch pods update in real-time
kubectl get pods -w
```

---

## Recreate Strategy

### Overview

Recreate strategy terminates all existing pods before creating new ones. Results in downtime but ensures only one version runs at a time.

### Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: recreate-app
spec:
  replicas: 5
  
  strategy:
    type: Recreate  # No additional parameters
    
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
        image: myapp:1.0
```

### When to Use Recreate

Use Recreate when:
- Multiple versions cannot run simultaneously (database schema changes)
- Application doesn't support graceful shutdown
- Development/testing environments where downtime is acceptable
- Cost optimization (don't need extra pods during update)

### Recreate Flow

```
Time 0: 5 pods running version 1.0
Time 1: All 5 pods terminate (downtime begins)
Time 2: Wait for termination to complete
Time 3: Create 5 new pods with version 2.0
Time 4: Wait for new pods to be ready (downtime ends)
```

---

## Blue-Green Deployments

### Overview

Blue-Green deployment runs two identical production environments. Only one serves traffic at a time. You switch between them by updating the Service selector.

### Implementation

```yaml
# Blue Deployment (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue
  template:
    metadata:
      labels:
        app: myapp
        version: blue
    spec:
      containers:
      - name: app
        image: myapp:1.0
---
# Green Deployment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: app
        image: myapp:2.0
---
# Service points to blue (current)
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    version: blue  # Traffic goes to blue
  ports:
  - port: 80
```

### Blue-Green Cutover

```bash
# Step 1: Deploy green version
kubectl apply -f app-green-deployment.yaml

# Step 2: Verify green is healthy
kubectl get pods -l version=green
kubectl exec -it <green-pod> -- curl localhost

# Step 3: Switch traffic to green
kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"green"}}}'

# Step 4: Monitor for issues
# If issues occur, instantly switch back
kubectl patch service myapp-service -p '{"spec":{"selector":{"version":"blue"}}}'

# Step 5: Once stable, remove blue
kubectl delete deployment app-blue
```

### Benefits

- Instant rollback (just switch Service selector)
- Test new version in production environment before cutover
- Zero downtime
- Simple rollback process

### Drawbacks

- Doubles resource requirements (both versions running)
- Database migrations can be complex
- Cost increase during deployment

---

## Canary Deployments

### Overview

Canary deployment gradually shifts traffic from old version to new version, allowing you to test with subset of users first.

### Implementation

```yaml
# Stable Deployment (v1 - 9 replicas)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-stable
spec:
  replicas: 9
  selector:
    matchLabels:
      app: myapp
      track: stable
  template:
    metadata:
      labels:
        app: myapp
        track: stable
        version: v1
    spec:
      containers:
      - name: app
        image: myapp:1.0
---
# Canary Deployment (v2 - 1 replica = 10% traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      track: canary
  template:
    metadata:
      labels:
        app: myapp
        track: canary
        version: v2
    spec:
      containers:
      - name: app
        image: myapp:2.0
---
# Service selects both stable and canary
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp  # Matches both stable and canary
  ports:
  - port: 80
```

### Canary Progression

```bash
# Phase 1: 10% canary (9 stable + 1 canary)
kubectl apply -f app-canary.yaml

# Monitor metrics, logs, errors for canary pods
kubectl logs -l track=canary --tail=100

# Phase 2: Increase to 25% (7.5 stable + 2.5 canary)
kubectl scale deployment app-stable --replicas=7
kubectl scale deployment app-canary --replicas=3

# Phase 3: 50% canary
kubectl scale deployment app-stable --replicas=5
kubectl scale deployment app-canary --replicas=5

# Phase 4: 100% canary - promote canary to stable
kubectl scale deployment app-canary --replicas=10
kubectl delete deployment app-stable

# Rename canary to stable
kubectl patch deployment app-canary -p '{"metadata":{"name":"app-stable"}}'
```

### Canary Rollback

```bash
# If issues detected, scale down canary immediately
kubectl scale deployment app-canary --replicas=0

# Or delete canary
kubectl delete deployment app-canary
```

### Benefits

- Test with real production traffic
- Gradual rollout minimizes impact
- Easy to rollback (scale down canary)
- Gain confidence before full rollout

### Drawbacks

- Complex to implement
- Requires monitoring and metrics
- Session affinity can cause issues
- Need traffic management (consider service mesh)

---

## Rollback Strategies

### Automatic Rollback

Configure automatic rollback on failure:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auto-rollback-app
spec:
  replicas: 5
  
  # Deployment will auto-rollback if update takes too long
  progressDeadlineSeconds: 600  # 10 minutes
  
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
      
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: myapp:2.0
        
        # Readiness probe - pods must pass to be "ready"
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          failureThreshold: 3
```

### Manual Rollback

```bash
# View rollout history
kubectl rollout history deployment/myapp

# Rollback to previous version
kubectl rollout undo deployment/myapp

# Rollback to specific revision
kubectl rollout undo deployment/myapp --to-revision=3

# Check rollback status
kubectl rollout status deployment/myapp
```

### Pause and Resume

```bash
# Pause rollout to inspect
kubectl rollout pause deployment/myapp

# Make changes without triggering new rollout
kubectl set image deployment/myapp app=myapp:3.0
kubectl set resources deployment/myapp app --limits=cpu=200m,memory=512Mi

# Resume when ready
kubectl rollout resume deployment/myapp
```

---

## Hands-On Labs

### Lab 1: Rolling Update with Custom Parameters

**Objective:** Configure and test rolling update

**Steps:**

1. Create deployment:
```yaml
# app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 3
      maxUnavailable: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: webapp
        image: nginx:1.21
        ports:
        - containerPort: 80
```

2. Apply and verify:
```bash
kubectl apply -f app-deployment.yaml
kubectl get pods -l app=webapp
```

3. Update to new version:
```bash
kubectl set image deployment/webapp webapp=nginx:1.22
```

4. Watch the rollout:
```bash
# Terminal 1
kubectl rollout status deployment/webapp

# Terminal 2
kubectl get pods -l app=webapp -w
```

5. Observe the update pattern:
- Note how many pods exist at once
- Check how many are unavailable at any time

### Lab 2: Blue-Green Deployment

**Objective:** Implement blue-green deployment

**Steps:**

1. Deploy blue version:
```bash
kubectl create deployment app-blue --image=nginx:1.21 --replicas=3
kubectl label deployment app-blue version=blue
kubectl patch deployment app-blue -p '{"spec":{"selector":{"matchLabels":{"version":"blue"}},"template":{"metadata":{"labels":{"version":"blue"}}}}}'
```

2. Create service pointing to blue:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    version: blue
  ports:
  - port: 80
```

3. Deploy green version:
```bash
kubectl create deployment app-green --image=nginx:1.22 --replicas=3
kubectl label deployment app-green version=green
kubectl patch deployment app-green -p '{"spec":{"selector":{"matchLabels":{"version":"green"}},"template":{"metadata":{"labels":{"version":"green"}}}}}'
```

4. Verify both are running:
```bash
kubectl get pods -l version=blue
kubectl get pods -l version=green
```

5. Switch traffic to green:
```bash
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'
```

6. Verify cutover:
```bash
kubectl describe service app-service | grep Selector
kubectl get endpoints app-service
```

7. Simulate rollback:
```bash
kubectl patch service app-service -p '{"spec":{"selector":{"version":"blue"}}}'
```

### Lab 3: Canary Deployment

**Objective:** Implement canary deployment

**Steps:**

1. Deploy stable version (90%):
```bash
kubectl create deployment app-stable --image=nginx:1.21 --replicas=9
kubectl label deployment app-stable track=stable
```

2. Deploy canary version (10%):
```bash
kubectl create deployment app-canary --image=nginx:1.22 --replicas=1
kubectl label deployment app-canary track=canary
```

3. Create service selecting both:
```bash
kubectl create service clusterip app --tcp=80:80
# Service selector matches both (no track label)
```

4. Verify traffic distribution:
```bash
# Check endpoints
kubectl get endpoints app

# Test distribution
for i in {1..20}; do kubectl exec -it <any-pod> -- curl -s app | grep -o "nginx/[0-9.]*"; done
```

5. Increase canary to 25%:
```bash
kubectl scale deployment app-stable --replicas=7
kubectl scale deployment app-canary --replicas=3
```

6. Promote canary to stable:
```bash
kubectl scale deployment app-canary --replicas=10
kubectl delete deployment app-stable
```

### Lab 4: Rollback Practice

**Objective:** Practice rollback scenarios

**Steps:**

1. Create deployment:
```bash
kubectl create deployment rollback-app --image=nginx:1.19 --replicas=3
```

2. Update to v1.20:
```bash
kubectl set image deployment/rollback-app rollback-app=nginx:1.20
kubectl rollout status deployment/rollback-app
```

3. Update to v1.21:
```bash
kubectl set image deployment/rollback-app rollback-app=nginx:1.21
```

4. View history:
```bash
kubectl rollout history deployment/rollback-app
```

5. Rollback to previous version:
```bash
kubectl rollout undo deployment/rollback-app
kubectl rollout status deployment/rollback-app
```

6. Verify rollback:
```bash
kubectl describe deployment rollback-app | grep Image
```

7. Rollback to specific revision:
```bash
kubectl rollout undo deployment/rollback-app --to-revision=1
```

### Lab 5: Pause and Resume

**Objective:** Control rollout process

**Steps:**

1. Create deployment:
```bash
kubectl create deployment pause-app --image=nginx:1.21 --replicas=5
```

2. Start update and immediately pause:
```bash
kubectl set image deployment/pause-app pause-app=nginx:1.22
kubectl rollout pause deployment/pause-app
```

3. Check status:
```bash
kubectl rollout status deployment/pause-app
kubectl get pods -l app=pause-app
```

4. Make additional changes while paused:
```bash
kubectl set resources deployment/pause-app pause-app --limits=cpu=200m,memory=256Mi
```

5. Resume rollout:
```bash
kubectl rollout resume deployment/pause-app
kubectl rollout status deployment/pause-app
```

### Lab 6: Cleanup

```bash
kubectl delete deployments --all
kubectl delete services --all
```

---

## Key Takeaways

1. **Rolling updates = zero downtime** - Default and recommended strategy
2. **Recreate = acceptable downtime** - Use when versions can't coexist
3. **Blue-green = instant cutover** - Test in prod, instant rollback
4. **Canary = gradual rollout** - Test with small percentage first
5. **Always use readiness probes** - Essential for safe rolling updates
6. **Monitor during updates** - Watch metrics, logs, errors
7. **Test rollback procedures** - Practice before you need them

---

## Next Steps

- **[Module 10: Cluster Maintenance](10-cluster-maintenance.md)** - Node management
- **[Module 13: Health Probes](13-health-probes.md)** - Essential for safe updates
- Practice with the example YAML files in `examples/update-strategies/`

---

## Additional Resources

- [Kubernetes Deployment Strategies](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)
- [Progressive Delivery](https://www.weave.works/blog/progressive-delivery)
- [kubectl Cheat Sheet](kubectl-cheatsheet.md)

---

**Congratulations!** You now know how to safely update and rollback applications in Kubernetes! 🎉
