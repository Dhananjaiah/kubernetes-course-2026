# Module 17: StatefulSets

## Overview

StatefulSets manage stateful applications that require stable network identities, persistent storage, and ordered deployment and scaling.

## Learning Objectives

- Understand when to use StatefulSets vs Deployments
- Create and manage StatefulSets
- Configure persistent storage for StatefulSets
- Understand StatefulSet scaling and updates

## StatefulSet vs Deployment

| Feature | Deployment | StatefulSet |
|---------|------------|-------------|
| Pod names | Random | Predictable (pod-0, pod-1) |
| Network identity | Random | Stable (pod-0.service) |
| Storage | Shared optional | Per-pod persistent |
| Scaling order | Random | Ordered (0→1→2) |
| Use case | Stateless apps | Stateful apps |

## When to Use StatefulSets

Use StatefulSets for:
- Databases (MySQL, PostgreSQL, MongoDB)
- Message queues (Kafka, RabbitMQ)
- Distributed systems (Zookeeper, etcd)
- Applications needing stable network identities

## StatefulSet Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-headless
spec:
  clusterIP: None  # Headless service
  selector:
    app: mysql
  ports:
  - port: 3306
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-headless  # Required
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
          name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  
  # VolumeClaimTemplates - creates PVC for each pod
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

## Key Features

### 1. Stable Network Identity

Each pod gets predictable DNS name:
```
<pod-name>.<service-name>.<namespace>.svc.cluster.local

Examples:
mysql-0.mysql-headless.default.svc.cluster.local
mysql-1.mysql-headless.default.svc.cluster.local
mysql-2.mysql-headless.default.svc.cluster.local
```

### 2. Ordered Deployment

Pods created in order: 0 → 1 → 2

```
Step 1: Create mysql-0, wait for it to be Running and Ready
Step 2: Create mysql-1, wait for it to be Running and Ready
Step 3: Create mysql-2, wait for it to be Running and Ready
```

### 3. Ordered Scaling

Scale up: Add pods in order (2 → 3)
Scale down: Remove pods in reverse (3 → 2)

```bash
# Scale up (adds mysql-3)
kubectl scale statefulset mysql --replicas=4

# Scale down (removes mysql-3)
kubectl scale statefulset mysql --replicas=3
```

### 4. Persistent Storage Per Pod

Each pod gets its own PVC from volumeClaimTemplates:
- mysql-0 → mysql-data-mysql-0
- mysql-1 → mysql-data-mysql-1
- mysql-2 → mysql-data-mysql-2

Storage persists even if pod is deleted and recreated.

## Complete Example: MongoDB ReplicaSet

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo
spec:
  clusterIP: None
  selector:
    app: mongo
  ports:
  - port: 27017
    name: mongo
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
spec:
  serviceName: mongo
  replicas: 3
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: mongo:5.0
        command:
        - mongod
        - "--replSet"
        - rs0
        - "--bind_ip_all"
        ports:
        - containerPort: 27017
          name: mongo
        volumeMounts:
        - name: mongo-data
          mountPath: /data/db
        env:
        - name: MONGO_INITDB_ROOT_USERNAME
          value: admin
        - name: MONGO_INITDB_ROOT_PASSWORD
          value: password
  volumeClaimTemplates:
  - metadata:
      name: mongo-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

## StatefulSet Operations

### View StatefulSet

```bash
# List StatefulSets
kubectl get statefulsets
kubectl get sts

# Describe StatefulSet
kubectl describe statefulset mongo

# View pods (note ordered names)
kubectl get pods -l app=mongo
```

### Scaling

```bash
# Scale up
kubectl scale statefulset mongo --replicas=5

# Scale down
kubectl scale statefulset mongo --replicas=3

# Edit replicas
kubectl edit statefulset mongo
```

### Updates

```bash
# Update image
kubectl set image statefulset/mongo mongo=mongo:5.1

# RollingUpdate (default) - updates in reverse order
# Updates mongo-2, then mongo-1, then mongo-0

# OnDelete - manual update
# Edit pod template, then manually delete pods to trigger update
```

### Delete StatefulSet

```bash
# Delete StatefulSet but keep pods
kubectl delete statefulset mongo --cascade=orphan

# Delete StatefulSet and pods (PVCs remain)
kubectl delete statefulset mongo

# Delete everything including PVCs
kubectl delete statefulset mongo
kubectl delete pvc -l app=mongo
```

## Update Strategies

### RollingUpdate (Default)

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0  # Update pods >= partition (2 means update 2,3,4... but not 0,1)
```

### OnDelete

```yaml
spec:
  updateStrategy:
    type: OnDelete  # Pods updated only when manually deleted
```

## Partition Update Example

```yaml
spec:
  replicas: 5
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 3  # Only update pods 3 and 4 (not 0, 1, 2)
```

Useful for canary testing: Update only high-numbered pods first.

## Hands-On Labs

### Lab 1: Basic StatefulSet

```bash
# Create StatefulSet
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nginx-headless
spec:
  clusterIP: None
  selector:
    app: nginx-sts
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: nginx-headless
  replicas: 3
  selector:
    matchLabels:
      app: nginx-sts
  template:
    metadata:
      labels:
        app: nginx-sts
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF

# Watch pods created in order
kubectl get pods -l app=nginx-sts -w

# Check DNS names
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
/ # nslookup web-0.nginx-headless
/ # nslookup web-1.nginx-headless
/ # nslookup web-2.nginx-headless
```

### Lab 2: Test Pod Identity Persistence

```bash
# Write unique data to each pod
for i in 0 1 2; do
  kubectl exec web-$i -- sh -c "echo 'I am web-$i' > /usr/share/nginx/html/index.html"
done

# Verify
for i in 0 1 2; do
  kubectl exec web-$i -- cat /usr/share/nginx/html/index.html
done

# Delete pod web-1
kubectl delete pod web-1

# Wait for recreation
kubectl wait --for=condition=ready pod web-1

# Data persists (because of PVC)
kubectl exec web-1 -- cat /usr/share/nginx/html/index.html
```

### Lab 3: Scaling StatefulSet

```bash
# Current replicas: 3
kubectl get statefulset web

# Scale up to 5
kubectl scale statefulset web --replicas=5

# Watch new pods created in order
kubectl get pods -l app=nginx-sts -w

# Scale down to 2
kubectl scale statefulset web --replicas=2

# Watch pods deleted in reverse order (web-4, then web-3)
kubectl get pods -l app=nginx-sts -w

# Note: PVCs remain even after scale down
kubectl get pvc
```

### Lab 4: Update Strategy

```bash
# Update image
kubectl set image statefulset/web nginx=nginx:1.22

# Watch update (reverse order: web-2, web-1, web-0)
kubectl get pods -l app=nginx-sts -w

# Check rollout status
kubectl rollout status statefulset/web
```

## Best Practices

1. **Always use headless service** - Required for stable network identity
2. **Set resource requests/limits** - For predictable performance
3. **Use volumeClaimTemplates** - For per-pod persistent storage
4. **Test updates carefully** - Use partition for canary updates
5. **Monitor pod order** - Understand ordered operations
6. **Backup data** - Before major updates or deletes
7. **Use init containers** - For setup tasks before main container

## Common Patterns

### Pattern 1: Database Primary-Replica

```yaml
# Primary: web-0
# Replicas: web-1, web-2, web-3
# App logic handles primary/replica roles based on pod ordinal
```

### Pattern 2: Distributed Consensus

```yaml
# Zookeeper, etcd, Consul
# Each pod is a voting member
# Stable identity crucial for cluster membership
```

### Pattern 3: Sharded Storage

```yaml
# Each pod handles a shard of data
# Pod ordinal determines shard assignment
# Stable storage per pod
```

## Key Takeaways

- **StatefulSets for stateful apps** - Databases, message queues
- **Stable network identity** - pod-0.service, pod-1.service
- **Ordered operations** - Creation, scaling, updates
- **Persistent storage per pod** - Via volumeClaimTemplates
- **Headless service required** - For stable DNS
- **Updates in reverse order** - pod-N to pod-0
- **PVCs persist after scale down** - Manual cleanup needed

## Next Steps

- **[Module 18: RBAC](18-rbac.md)**
- Practice with examples in `examples/statefulsets/`

## Additional Resources

- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Run a Replicated Stateful Application](https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)
