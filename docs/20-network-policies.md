# Module 20: Network Policies

## Overview

Network Policies are Kubernetes resources that control traffic flow between pods and network endpoints. They act as a firewall for your applications.

## Learning Objectives

- Understand Network Policies
- Control pod-to-pod communication
- Implement ingress and egress rules
- Secure applications with network isolation

## Why Network Policies?

### Default Behavior (No NetworkPolicy)

```
All pods can communicate with all pods
Pod A → Pod B ✅
Pod C → Pod D ✅
External → Any Pod ✅
```

### With Network Policies

```
Explicitly allow traffic
Frontend → Backend ✅
Backend → Database ✅
Frontend → Database ❌ (denied)
```

## Prerequisites

Network Policies require a CNI plugin that supports them:
- **Calico** ✅
- **Cilium** ✅
- **Weave Net** ✅
- **Flannel** ❌ (doesn't support)

## Basic Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  # Apply to all pods in namespace
  podSelector: {}
  
  # Deny all traffic (no ingress/egress rules)
  policyTypes:
  - Ingress
  - Egress
```

## Ingress Policy (Incoming Traffic)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
  namespace: production
spec:
  # Apply to pods with label app=backend
  podSelector:
    matchLabels:
      app: backend
  
  policyTypes:
  - Ingress
  
  ingress:
  # Allow traffic from pods with label app=frontend
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## Egress Policy (Outgoing Traffic)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: frontend
  
  policyTypes:
  - Egress
  
  egress:
  # Allow traffic to pods with label app=backend
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 8080
  
  # Allow DNS queries
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

## Selector Types

### 1. podSelector

Selects pods in same namespace:

```yaml
ingress:
- from:
  - podSelector:
      matchLabels:
        app: frontend
```

### 2. namespaceSelector

Selects all pods in matching namespaces:

```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        environment: production
```

### 3. podSelector + namespaceSelector (AND)

```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        environment: production
    podSelector:
      matchLabels:
        app: frontend
```

### 4. Multiple Rules (OR)

```yaml
ingress:
# Rule 1: Allow from frontend pods
- from:
  - podSelector:
      matchLabels:
        app: frontend

# Rule 2: OR allow from monitoring namespace
- from:
  - namespaceSelector:
      matchLabels:
        name: monitoring
```

### 5. ipBlock

Allow/deny specific IP ranges:

```yaml
ingress:
- from:
  - ipBlock:
      cidr: 192.168.1.0/24
      except:
      - 192.168.1.10/32
```

## Common Patterns

### Pattern 1: Default Deny All

```yaml
# Deny all ingress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
# Deny all egress traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

### Pattern 2: Allow All (Explicit)

```yaml
# Allow all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - {}  # Empty rule = allow all
---
# Allow all egress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-egress
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - {}  # Empty rule = allow all
```

### Pattern 3: Three-Tier Application

```yaml
# Frontend → Backend only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-policy
spec:
  podSelector:
    matchLabels:
      tier: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 8080
---
# Backend → Database only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-policy
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: database
    ports:
    - protocol: TCP
      port: 5432
---
# Database → Accept from backend only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-policy
spec:
  podSelector:
    matchLabels:
      tier: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 5432
```

### Pattern 4: Allow External Traffic

```yaml
# Allow ingress from internet (via LoadBalancer)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0  # Allow from anywhere
    ports:
    - protocol: TCP
      port: 80
    - protocol: TCP
      port: 443
```

### Pattern 5: Allow DNS

```yaml
# Allow DNS queries (required for most apps)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
```

## Complete Example

```yaml
# Namespace with default deny
apiVersion: v1
kind: Namespace
metadata:
  name: secure-app
  labels:
    environment: production
---
# Default deny all
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: secure-app
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Frontend policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-netpol
  namespace: secure-app
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Allow from internet
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 80
  
  egress:
  # Allow to backend
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 8080
  # Allow DNS
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
---
# Backend policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-netpol
  namespace: secure-app
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Allow from frontend
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  
  egress:
  # Allow to database
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
  # Allow DNS
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
---
# Database policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-netpol
  namespace: secure-app
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  - Egress
  
  ingress:
  # Allow from backend only
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 5432
  
  egress:
  # Allow DNS only
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
```

## Hands-On Labs

### Lab 1: Default Deny

```bash
# Create namespace
kubectl create namespace netpol-test

# Create test pods
kubectl run frontend --image=nginx --namespace=netpol-test -l app=frontend
kubectl run backend --image=nginx --namespace=netpol-test -l app=backend

# Test connectivity (should work)
kubectl exec -n netpol-test frontend -- curl -m 3 backend

# Apply default deny
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: netpol-test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Test connectivity (should fail)
kubectl exec -n netpol-test frontend -- curl -m 3 backend
```

### Lab 2: Allow Specific Traffic

```bash
# Allow frontend → backend
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: netpol-test
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-egress
  namespace: netpol-test
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 80
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
EOF

# Test connectivity (should work now)
kubectl exec -n netpol-test frontend -- curl -m 3 backend
```

### Lab 3: Cross-Namespace

```bash
# Create two namespaces
kubectl create namespace ns1
kubectl create namespace ns2
kubectl label namespace ns1 env=test
kubectl label namespace ns2 env=test

# Create pods
kubectl run pod1 --image=nginx -n ns1 -l app=pod1
kubectl run pod2 --image=nginx -n ns2 -l app=pod2

# Allow ns1 → ns2
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-ns1
  namespace: ns2
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          env: test
      podSelector:
        matchLabels:
          app: pod1
EOF

# Test
POD2_IP=$(kubectl get pod pod2 -n ns2 -o jsonpath='{.status.podIP}')
kubectl exec -n ns1 pod1 -- curl -m 3 $POD2_IP
```

## Best Practices

1. **Start with default deny** - Then explicitly allow
2. **Label everything** - Pods, namespaces
3. **Test policies** - Verify before production
4. **Allow DNS** - Most apps need it
5. **Document policies** - Why each rule exists
6. **Use namespace labels** - For cross-namespace policies
7. **Monitor denied traffic** - CNI logs show denials

## Troubleshooting

```bash
# List network policies
kubectl get networkpolicies
kubectl get netpol

# Describe policy
kubectl describe networkpolicy <name>

# Check pod labels
kubectl get pods --show-labels

# Check namespace labels
kubectl get namespaces --show-labels

# Test connectivity
kubectl exec <pod> -- curl -m 3 <target>

# Check CNI logs (Calico example)
kubectl logs -n kube-system -l k8s-app=calico-node
```

## Key Takeaways

- **NetworkPolicies = pod firewall** - Control traffic flow
- **Default allow without policies** - Explicit denial needed
- **podSelector selects targets** - Which pods policy applies to
- **ingress = incoming, egress = outgoing** - Specify both
- **Requires CNI support** - Not all CNIs support policies
- **Labels are crucial** - For selectors to work
- **Default deny is best practice** - Then allow as needed

## Next Steps

- **[Module 21: Helm](21-helm.md)**
- Practice with examples in `examples/network-policies/`

## Additional Resources

- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)
