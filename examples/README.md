# Kubernetes Examples

This directory contains example YAML manifests for various Kubernetes resources. These examples are referenced throughout the course modules.

## Directory Structure

```
examples/
├── pods/                  # Pod examples
│   ├── simple-pod.yaml
│   ├── multi-container-pod.yaml
│   ├── pod-with-resources.yaml
│   └── pod-with-env.yaml
│
├── deployments/          # Deployment examples
│   └── simple-deployment.yaml
│
├── services/             # Service examples
│   ├── clusterip-service.yaml
│   └── nodeport-service.yaml
│
├── configmaps/          # ConfigMap examples
│   └── configmap.yaml
│
├── secrets/             # Secret examples
│   └── secret.yaml
│
├── ingress/             # Ingress examples
│   └── (to be added)
│
├── network-policies/    # NetworkPolicy examples
│   └── (to be added)
│
├── storage/             # Storage examples
│   └── (to be added)
│
└── helm/                # Helm chart examples
    └── (to be added)
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

- Module 3: Pods
- Module 6: Deployments
- Module 8: Services
- Module 12: ConfigMaps & Secrets
- Module 19: Ingress
- Module 21: Helm
