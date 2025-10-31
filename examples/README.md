# Kubernetes Examples

This directory contains example YAML manifests for various Kubernetes resources. These examples are referenced throughout the course modules.

## Directory Structure

```
examples/
├── pods/                      # Module 3: Pods
│   ├── simple-pod.yaml
│   ├── multi-container-pod.yaml
│   ├── pod-with-resources.yaml
│   └── pod-with-env.yaml
│
├── replicasets/              # Module 5: ReplicaSets
│   ├── simple-replicaset.yaml
│   ├── replicaset-with-resources.yaml
│   └── replicaset-multiple-labels.yaml
│
├── deployments/              # Module 6: Deployments
│   ├── simple-deployment.yaml
│   ├── deployment-rolling-update.yaml
│   ├── deployment-recreate.yaml
│   └── deployment-with-revision-history.yaml
│
├── labels/                   # Module 7: Labels & Selectors
│   ├── pod-with-labels.yaml
│   ├── deployment-with-selectors.yaml
│   └── service-with-selector.yaml
│
├── services/                 # Module 8: Services
│   ├── clusterip-service.yaml
│   ├── nodeport-service.yaml
│   ├── loadbalancer-service.yaml
│   └── headless-service.yaml
│
├── update-strategies/        # Module 9: Update Strategies
│   ├── blue-green-deployment.yaml
│   └── canary-deployment.yaml
│
├── daemonsets/               # Module 11: DaemonSets
│   └── node-logger-daemonset.yaml
│
├── jobs/                     # Module 11: Jobs
│   └── batch-job.yaml
│
├── cronjobs/                 # Module 11: CronJobs
│   └── backup-cronjob.yaml
│
├── configmaps/               # Module 12: ConfigMaps
│   └── configmap.yaml
│
├── secrets/                  # Module 12: Secrets
│   └── secret.yaml
│
├── health-probes/            # Module 13: Health Probes
│   └── pod-with-probes.yaml
│
├── scheduling/               # Module 14: Node Scheduling
│   └── pod-with-node-affinity.yaml
│
├── storage/                  # Module 16: Storage & Persistence
│   └── pvc-example.yaml
│
├── statefulsets/             # Module 17: StatefulSets
│   └── mongodb-statefulset.yaml
│
├── rbac/                     # Module 18: RBAC
│   └── developer-role.yaml
│
├── ingress/                  # Module 19: Ingress
│   └── complete-ingress.yaml
│
└── network-policies/         # Module 20: Network Policies
    └── three-tier-app-network-policy.yaml
```

## How to Use

### Apply a Single Example

```bash
kubectl apply -f examples/pods/simple-pod.yaml
```

### Apply All Examples in a Directory

```bash
kubectl apply -f examples/pods/
```

### Apply with Namespace

```bash
kubectl apply -f examples/pods/simple-pod.yaml -n development
```

### View Applied Resources

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

### Delete Resources

```bash
kubectl delete -f examples/pods/simple-pod.yaml
```

## Testing Examples

Most examples can be tested in a local Kubernetes cluster (Minikube, kind, etc.):

```bash
# Start Minikube if not running
minikube start

# Apply an example
kubectl apply -f examples/pods/simple-pod.yaml

# Verify it's running
kubectl get pods

# Test the application
kubectl port-forward pod/nginx-pod 8080:80
# Visit http://localhost:8080 in your browser

# Clean up
kubectl delete -f examples/pods/simple-pod.yaml
```

## Example Categories

### 1. Basic Resources
- Pods
- Deployments
- Services
- ConfigMaps
- Secrets

### 2. Networking
- Services (ClusterIP, NodePort, LoadBalancer)
- Ingress
- Network Policies

### 3. Storage
- Persistent Volumes
- Persistent Volume Claims
- StatefulSets

### 4. Configuration
- ConfigMaps for application configuration
- Secrets for sensitive data
- Environment variables

### 5. Advanced
- Helm charts
- Custom Resource Definitions (CRDs)
- Operators

## Notes

- All examples use standard Kubernetes resources
- Examples are designed for educational purposes
- For production use, add appropriate:
  - Resource limits
  - Security contexts
  - Health checks
  - Monitoring labels

## Contributing

When adding new examples:
1. Use clear, descriptive filenames
2. Add comments explaining key sections
3. Follow Kubernetes best practices
4. Test examples before committing
5. Update this README with the new example

## Related Course Modules

- Module 3: Pods & Pod Lifecycle
- Module 5: ReplicaSets
- Module 6: Deployments
- Module 7: Labels & Selectors
- Module 8: Services
- Module 9: Update Strategies & Rollback
- Module 11: DaemonSets, Jobs & CronJobs
- Module 12: ConfigMaps & Secrets
- Module 13: Health Probes
- Module 14: Node Scheduling
- Module 16: Storage & Persistence
- Module 17: StatefulSets
- Module 18: RBAC
- Module 19: Ingress
- Module 20: Network Policies
- Module 21: Helm
