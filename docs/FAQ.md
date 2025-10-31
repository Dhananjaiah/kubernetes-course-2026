# Frequently Asked Questions (FAQ)

## General Questions

### What is Kubernetes?

Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. It was originally developed by Google and is now maintained by the Cloud Native Computing Foundation (CNCF).

### Do I need to know Docker before learning Kubernetes?

Yes, basic Docker knowledge is recommended. Module 1 of this course covers Docker fundamentals, but having some prior experience with containers will help you understand Kubernetes concepts more quickly.

### What are the prerequisites for this course?

- Basic Linux command line skills
- Understanding of basic networking concepts
- A computer with at least 8GB RAM
- Docker installed (covered in Module 0)
- kubectl and Minikube installed (covered in Module 0)

### How long does it take to complete this course?

The course is designed to be completed in 8-12 weeks at a pace of 3-5 hours per week:
- Beginner track: Modules 1-8 (4 weeks)
- Intermediate track: Modules 9-15 (4 weeks)
- Advanced track: Modules 16-21 (4 weeks)

You can go faster or slower based on your schedule and experience level.

---

## Installation & Setup

### My Minikube won't start. What should I do?

Common solutions:

```bash
# Delete and recreate cluster
minikube delete
minikube start

# Try with different driver
minikube start --driver=docker
minikube start --driver=virtualbox

# Increase resources
minikube start --cpus=4 --memory=8192

# Check system resources
docker system df
docker system prune -a
```

### How do I check if my Kubernetes cluster is working?

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system
```

All nodes should show "Ready" status and system pods should be "Running".

### Can I use alternatives to Minikube?

Yes! Other options include:
- **kind** (Kubernetes in Docker) - lightweight and fast
- **k3s** - lightweight Kubernetes distribution
- **Docker Desktop** - includes Kubernetes
- **MicroK8s** - Ubuntu's lightweight Kubernetes

The course examples work with any of these.

---

## Working with Pods

### Why is my Pod stuck in "Pending" state?

Common causes:
1. **Insufficient resources**: No node has enough CPU/memory
   ```bash
   kubectl describe pod <pod-name>
   # Look for "FailedScheduling" events
   ```

2. **Image pull issues**: Cannot pull the container image
   ```bash
   kubectl describe pod <pod-name>
   # Look for "ErrImagePull" or "ImagePullBackOff"
   ```

3. **Node selector mismatch**: No nodes match the selector
   ```bash
   kubectl describe pod <pod-name>
   # Check node selector and available nodes
   ```

### What does "CrashLoopBackOff" mean?

It means your container keeps crashing and Kubernetes is repeatedly trying to restart it with increasing delays.

**Debug steps:**
```bash
# View current logs
kubectl logs <pod-name>

# View previous container logs
kubectl logs <pod-name> --previous

# Check events
kubectl describe pod <pod-name>

# Get shell access (if container runs)
kubectl exec -it <pod-name> -- sh
```

Common causes:
- Application error on startup
- Missing environment variables
- Configuration issues
- Resource limits too low

### How do I view logs from multiple containers in a Pod?

```bash
# Specify container name
kubectl logs <pod-name> -c <container-name>

# View logs from all containers
kubectl logs <pod-name> --all-containers=true

# Follow logs from specific container
kubectl logs -f <pod-name> -c <container-name>
```

---

## Deployments & Scaling

### What's the difference between a Pod and a Deployment?

- **Pod**: Single instance of your application, not managed
- **Deployment**: Manages multiple Pod replicas, handles updates and rollbacks

Always use Deployments in production, not bare Pods.

### How do I scale my application?

```bash
# Scale to 5 replicas
kubectl scale deployment <deployment-name> --replicas=5

# Or edit the deployment
kubectl edit deployment <deployment-name>
# Change spec.replicas to desired number
```

### How do I update my application to a new version?

```bash
# Update image
kubectl set image deployment/<deployment-name> \
  <container-name>=<new-image>:<new-tag>

# Check rollout status
kubectl rollout status deployment/<deployment-name>

# View rollout history
kubectl rollout history deployment/<deployment-name>
```

### How do I rollback a failed deployment?

```bash
# Rollback to previous version
kubectl rollout undo deployment/<deployment-name>

# Rollback to specific revision
kubectl rollout undo deployment/<deployment-name> --to-revision=2

# Check rollout history
kubectl rollout history deployment/<deployment-name>
```

---

## Services & Networking

### I can't access my Service. What's wrong?

**Check service is running:**
```bash
kubectl get svc <service-name>
kubectl describe svc <service-name>
```

**Check endpoints:**
```bash
kubectl get endpoints <service-name>
```

If no endpoints, your service selector doesn't match any pods.

**Test from within cluster:**
```bash
kubectl run test --image=busybox -it --rm -- wget -O- <service-name>:<port>
```

### What's the difference between ClusterIP, NodePort, and LoadBalancer?

| Type | Access | Use Case |
|------|--------|----------|
| **ClusterIP** | Internal only | Default, for pod-to-pod communication |
| **NodePort** | External via node IP:port | Development, on-premise |
| **LoadBalancer** | External via cloud LB | Production, cloud environments |

### How do I expose a Deployment as a Service?

```bash
# ClusterIP (internal only)
kubectl expose deployment <name> --port=80

# NodePort (external access)
kubectl expose deployment <name> --type=NodePort --port=80

# LoadBalancer (cloud environments)
kubectl expose deployment <name> --type=LoadBalancer --port=80
```

---

## Configuration & Secrets

### Should I use ConfigMaps or Secrets?

- **ConfigMaps**: Non-sensitive configuration (database host, feature flags, etc.)
- **Secrets**: Sensitive data (passwords, API keys, certificates)

Secrets are base64 encoded (not encrypted by default) and should be combined with RBAC and encryption at rest.

### How do I create a Secret from a file?

```bash
# From literal values
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpass

# From files
kubectl create secret generic my-secret \
  --from-file=username.txt \
  --from-file=password.txt

# From .env file
kubectl create secret generic my-secret \
  --from-env-file=.env
```

### How do I use ConfigMap in a Pod?

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: myapp:v1
    # As environment variables
    envFrom:
    - configMapRef:
        name: app-config
    # Or mount as files
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

---

## Troubleshooting

### How do I debug a failing Pod?

**Step-by-step debugging:**

```bash
# 1. Check pod status
kubectl get pod <pod-name>

# 2. Describe pod (check events)
kubectl describe pod <pod-name>

# 3. Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous container

# 4. Check resource usage
kubectl top pod <pod-name>

# 5. Get shell access
kubectl exec -it <pod-name> -- sh

# 6. Check node status
kubectl get nodes
kubectl describe node <node-name>
```

### Where can I find more detailed logs?

```bash
# Kubernetes component logs (on control plane node)
# API server
journalctl -u kube-apiserver

# Kubelet (on any node)
journalctl -u kubelet

# For Minikube
minikube logs
```

### How do I completely reset my Kubernetes cluster?

```bash
# For Minikube
minikube delete
minikube start

# Delete all resources in a namespace
kubectl delete all --all -n <namespace>

# Delete all resources in all namespaces (dangerous!)
kubectl delete all --all --all-namespaces
```

---

## Best Practices

### Should I use imperative or declarative commands?

- **Imperative** (`kubectl run`, `kubectl create`): Quick testing and experiments
- **Declarative** (YAML files with `kubectl apply`): Production deployments

**Always use YAML files for production** - they're version controllable, reviewable, and reproducible.

### How do I organize my Kubernetes manifests?

Recommended structure:
```
project/
├── base/                    # Base configurations
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── overlays/
│   ├── dev/                # Development environment
│   ├── staging/            # Staging environment
│   └── production/         # Production environment
└── scripts/
    └── deploy.sh
```

Consider using **Kustomize** or **Helm** for managing multiple environments.

### What are the most important security best practices?

1. **Don't run as root**: Use non-root users in containers
2. **Use RBAC**: Limit access with Role-Based Access Control
3. **Scan images**: Use trusted base images and scan for vulnerabilities
4. **Network policies**: Restrict pod-to-pod communication
5. **Secrets management**: Use Secrets, not ConfigMaps for sensitive data
6. **Resource limits**: Always set CPU/memory limits
7. **Keep updated**: Regularly update Kubernetes and dependencies

---

## Getting Help

### Where can I get more help?

1. **Course Materials**: Check module documentation
2. **Kubernetes Docs**: https://kubernetes.io/docs/
3. **Community Slack**: https://kubernetes.slack.com/
4. **Stack Overflow**: Tag questions with `kubernetes`
5. **GitHub Issues**: For bugs in this course repository

### How do I report issues with this course?

Open an issue in the GitHub repository with:
- Module number and topic
- What you expected
- What actually happened
- Your environment (OS, Kubernetes version, etc.)
- Steps to reproduce

---

## Next Steps

### I've completed the course. What's next?

**Certifications:**
- CKA (Certified Kubernetes Administrator)
- CKAD (Certified Kubernetes Application Developer)
- CKS (Certified Kubernetes Security Specialist)

**Advanced Topics:**
- Service meshes (Istio, Linkerd)
- GitOps (ArgoCD, Flux)
- Observability (Prometheus, Grafana)
- CI/CD integration
- Multi-cluster management

**Practice:**
- Build real projects
- Contribute to open source
- Set up production-like environments
- Learn cloud provider Kubernetes offerings (EKS, GKE, AKS)

---

**Still have questions?** Open an issue in the repository or check the course modules for detailed information!
