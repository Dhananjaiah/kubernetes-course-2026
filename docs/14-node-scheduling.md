# Module 14: Node Scheduling

## Overview

Learn how to control which nodes your pods run on using node selectors, node affinity, and pod affinity/anti-affinity rules.

## Learning Objectives

- Use nodeSelector for simple node selection
- Configure node affinity for advanced node selection
- Implement pod affinity and anti-affinity
- Understand scheduling constraints and preferences

## Node Selection Methods

### 1. nodeName (Direct Assignment)

Simplest but inflexible - assigns pod to specific node.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-nodename
spec:
  nodeName: node-1  # Bypasses scheduler, directly assigns to node-1
  containers:
  - name: nginx
    image: nginx
```

### 2. nodeSelector (Label-based)

Simple label matching - pod runs on nodes with matching labels.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-nodeselector
spec:
  nodeSelector:
    disktype: ssd      # Runs on nodes labeled disktype=ssd
    environment: production
  containers:
  - name: nginx
    image: nginx
```

**Label nodes:**
```bash
kubectl label nodes node-1 disktype=ssd
kubectl label nodes node-1 environment=production
```

### 3. Node Affinity (Advanced Selection)

More expressive than nodeSelector - supports operators and preferences.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-affinity
spec:
  affinity:
    nodeAffinity:
      # REQUIRED: Pod won't schedule if no matching node
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
            - nvme
          - key: environment
            operator: NotIn
            values:
            - development
      
      # PREFERRED: Scheduler tries to match, but not required
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: region
            operator: In
            values:
            - us-west-1
  containers:
  - name: nginx
    image: nginx
```

**Node Affinity Operators:**
- `In`: Label value in list
- `NotIn`: Label value not in list
- `Exists`: Label key exists
- `DoesNotExist`: Label key doesn't exist
- `Gt`: Greater than (numeric)
- `Lt`: Less than (numeric)

## Pod Affinity & Anti-Affinity

### Pod Affinity

Schedule pods together (co-location).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-frontend
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - cache
        topologyKey: kubernetes.io/hostname  # Same node
  containers:
  - name: web
    image: nginx
```

### Pod Anti-Affinity

Spread pods apart (avoid co-location).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-1
  labels:
    app: web
spec:
  affinity:
    podAntiAffinity:
      # Don't schedule on same node as other 'web' pods
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            app: web
        topologyKey: kubernetes.io/hostname
  containers:
  - name: web
    image: nginx
```

### Topology Keys

- `kubernetes.io/hostname`: Same node
- `topology.kubernetes.io/zone`: Same availability zone
- `topology.kubernetes.io/region`: Same region

## Complete Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      affinity:
        # Node affinity: Prefer SSD nodes in us-west
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 80
            preference:
              matchExpressions:
              - key: disktype
                operator: In
                values:
                - ssd
          - weight: 20
            preference:
              matchExpressions:
              - key: region
                operator: In
                values:
                - us-west-1
        
        # Pod anti-affinity: Spread across nodes
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: web
              topologyKey: kubernetes.io/hostname
      
      containers:
      - name: web
        image: nginx:1.21
```

## Hands-On Labs

### Lab 1: nodeSelector

```bash
# Label node
kubectl label nodes <node-name> disktype=ssd

# Create pod with nodeSelector
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-ssd
spec:
  nodeSelector:
    disktype: ssd
  containers:
  - name: nginx
    image: nginx
EOF

# Verify pod placement
kubectl get pod nginx-ssd -o wide

# Remove label and observe
kubectl label nodes <node-name> disktype-
```

### Lab 2: Node Affinity

```bash
# Label nodes
kubectl label nodes node-1 disktype=ssd environment=prod
kubectl label nodes node-2 disktype=hdd environment=dev

# Create pod with node affinity
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
          - key: environment
            operator: In
            values:
            - prod
  containers:
  - name: nginx
    image: nginx
EOF

# Verify placement
kubectl get pod nginx-affinity -o wide
```

### Lab 3: Pod Anti-Affinity

```bash
# Create deployment with anti-affinity
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-spread
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-spread
  template:
    metadata:
      labels:
        app: web-spread
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: web-spread
            topologyKey: kubernetes.io/hostname
      containers:
      - name: nginx
        image: nginx
EOF

# Verify pods are on different nodes
kubectl get pods -l app=web-spread -o wide
```

## Best Practices

1. **Use nodeSelector for simple cases** - Easy and clear
2. **Use node affinity for complex rules** - More flexible
3. **Use pod anti-affinity for HA** - Spread replicas across nodes/zones
4. **Use pod affinity for performance** - Co-locate dependent services
5. **Prefer soft constraints** - Use "preferred" over "required" when possible

## Key Takeaways

- **nodeSelector**: Simple label-based node selection
- **Node Affinity**: Advanced node selection with operators
- **Pod Affinity**: Co-locate pods
- **Pod Anti-Affinity**: Spread pods apart
- **Required vs Preferred**: Hard vs soft constraints
- **topologyKey**: Defines scope (node, zone, region)

## Next Steps

- **[Module 15: Taints & Tolerations](15-taints-tolerations.md)**

## Additional Resources

- [Kubernetes Node Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
