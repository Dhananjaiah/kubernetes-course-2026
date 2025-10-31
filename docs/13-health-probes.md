# Module 13: Health Probes

## Overview

Health probes ensure that Kubernetes knows when your application is healthy and ready to serve traffic. They are essential for reliable deployments and auto-healing.

## Learning Objectives

- Understand liveness, readiness, and startup probes
- Configure HTTP, TCP, and exec probes
- Implement health check best practices
- Troubleshoot probe failures

## Probe Types

### 1. Liveness Probe

**Purpose**: Detect if application is alive
- **Fails**: Kubernetes restarts the container
- **Use when**: Application can deadlock or hang

### 2. Readiness Probe

**Purpose**: Detect if application is ready to serve traffic
- **Fails**: Pod removed from Service endpoints
- **Use when**: Application needs startup time or dependency checks

### 3. Startup Probe

**Purpose**: Detect if application has started (for slow-starting apps)
- **Fails**: Container restarted
- **Use when**: Application has long startup time

## Probe Mechanisms

### HTTP GET Probe

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
    httpHeaders:
    - name: Custom-Header
      value: Value
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 1
  successThreshold: 1
  failureThreshold: 3
```

### TCP Socket Probe

```yaml
livenessProbe:
  tcpSocket:
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 10
```

### Exec Probe

```yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Probe Configuration

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-example
spec:
  containers:
  - name: app
    image: myapp:1.0
    ports:
    - containerPort: 8080
    
    # Startup probe (checked first, for slow-starting apps)
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 10
      failureThreshold: 30  # 30 * 10s = 5 min max startup time
    
    # Liveness probe (is app alive?)
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
      timeoutSeconds: 1
      successThreshold: 1
      failureThreshold: 3
    
    # Readiness probe (is app ready for traffic?)
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 1
      successThreshold: 1
      failureThreshold: 3
```

## Probe Parameters

- **initialDelaySeconds**: Wait before first probe (default: 0)
- **periodSeconds**: How often to probe (default: 10)
- **timeoutSeconds**: Probe timeout (default: 1)
- **successThreshold**: Consecutive successes needed (default: 1)
- **failureThreshold**: Consecutive failures before action (default: 3)

## Common Patterns

### Pattern 1: Web Application

```yaml
# Liveness: Check if app is responding
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

# Readiness: Check if app and dependencies are ready
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
```

### Pattern 2: Database

```yaml
# Liveness: Check if database is running
livenessProbe:
  tcpSocket:
    port: 5432
  initialDelaySeconds: 60
  periodSeconds: 10

# Readiness: Check if database accepts connections
readinessProbe:
  exec:
    command:
    - pg_isready
    - -U
    - postgres
  initialDelaySeconds: 30
  periodSeconds: 10
```

### Pattern 3: Slow-Starting Application

```yaml
# Startup probe: Give app 5 minutes to start
startupProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 10
  failureThreshold: 30  # 30 * 10s = 5 minutes

# Liveness: After startup, check every 10s
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 10
```

## Hands-On Labs

### Lab 1: HTTP Health Probe

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: http-probe-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 3
      periodSeconds: 3
    
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

```bash
# Apply pod
kubectl apply -f http-probe-pod.yaml

# Watch pod status
kubectl get pod http-probe-pod -w

# Check probe results
kubectl describe pod http-probe-pod | grep -A 10 "Liveness\|Readiness"
```

### Lab 2: Failing Probe Simulation

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: failing-probe
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "touch /tmp/healthy && sleep 30 && rm /tmp/healthy && sleep 600"]
    
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

```bash
# Apply pod
kubectl apply -f failing-probe.yaml

# Watch pod restart after 30 seconds
kubectl get pod failing-probe -w

# Check events
kubectl describe pod failing-probe | grep -A 10 Events
```

### Lab 3: Startup Probe for Slow Apps

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: slow-startup
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "sleep 60 && touch /tmp/ready && sleep 3600"]
    
    # Startup probe: Wait up to 2 minutes
    startupProbe:
      exec:
        command:
        - cat
        - /tmp/ready
      periodSeconds: 10
      failureThreshold: 12  # 12 * 10s = 2 minutes
    
    # Liveness: After startup
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/ready
      periodSeconds: 10
```

## Best Practices

### 1. Always Use Readiness Probes

```yaml
# ✅ Good - App removed from service when not ready
readinessProbe:
  httpGet:
    path: /ready
    port: 8080

# ❌ Bad - No readiness probe, traffic sent to broken pods
# No readiness probe defined
```

### 2. Use Startup Probes for Slow Apps

```yaml
# ✅ Good - Gives app time to start
startupProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 10
  failureThreshold: 30  # 5 minutes max

# ❌ Bad - Liveness probe kills slow-starting app
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  failureThreshold: 3  # Only 30 seconds before restart
```

### 3. Keep Probes Lightweight

```yaml
# ✅ Good - Quick health check
livenessProbe:
  httpGet:
    path: /health  # Returns in <100ms
    port: 8080

# ❌ Bad - Expensive probe
livenessProbe:
  httpGet:
    path: /full-system-check  # Database queries, slow
    port: 8080
```

### 4. Set Appropriate Thresholds

```yaml
# ✅ Good - Tolerates transient failures
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 10
  failureThreshold: 3  # 30 seconds of failures before restart

# ❌ Bad - Too aggressive
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  periodSeconds: 1
  failureThreshold: 1  # Restarts after 1 second
```

### 5. Different Endpoints for Different Probes

```yaml
# ✅ Good - Separate concerns
livenessProbe:
  httpGet:
    path: /health  # Just checks app is alive

readinessProbe:
  httpGet:
    path: /ready  # Checks app + dependencies
```

## Troubleshooting

### Probe Failing

```bash
# Check probe configuration
kubectl describe pod <pod-name> | grep -A 10 "Liveness\|Readiness"

# Check events
kubectl describe pod <pod-name> | grep -A 10 Events

# Check logs
kubectl logs <pod-name>

# Test probe manually
kubectl exec <pod-name> -- wget -O- http://localhost:8080/health
```

### Pod Stuck in Not Ready

```bash
# Check readiness probe
kubectl describe pod <pod-name> | grep -A 5 Readiness

# Check if port is correct
kubectl exec <pod-name> -- netstat -tuln | grep 8080

# Check application logs
kubectl logs <pod-name>
```

### Pod Restarting Frequently

```bash
# Check liveness probe
kubectl describe pod <pod-name> | grep -A 5 Liveness

# Check restart count
kubectl get pod <pod-name>

# View previous container logs
kubectl logs <pod-name> --previous
```

## Key Takeaways

1. **Always use readiness probes** - Prevent traffic to broken pods
2. **Use liveness probes carefully** - Only for deadlock detection
3. **Use startup probes for slow apps** - Prevent premature restarts
4. **Keep probes lightweight** - Fast response times
5. **Set appropriate thresholds** - Tolerate transient failures
6. **Separate health and readiness** - Different endpoints
7. **Test probes thoroughly** - In development and staging

## Next Steps

- **[Module 14: Node Scheduling](14-node-scheduling.md)**
- Practice with examples in `examples/health-probes/`

## Additional Resources

- [Kubernetes Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Health Checks Best Practices](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)
