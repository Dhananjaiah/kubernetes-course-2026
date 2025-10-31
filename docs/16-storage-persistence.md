# Module 16: Storage & Persistence

## Overview

Learn how to provide persistent storage to applications in Kubernetes using Volumes, Persistent Volumes (PV), Persistent Volume Claims (PVC), and Storage Classes.

## Learning Objectives

- Understand Kubernetes storage concepts
- Use Volumes for temporary storage
- Create and use Persistent Volumes
- Use Storage Classes for dynamic provisioning
- Configure storage for stateful applications

## Volume Types

### 1. emptyDir (Temporary)

Empty directory created when pod starts, deleted when pod deleted.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: cache
      mountPath: /cache
  volumes:
  - name: cache
    emptyDir: {}  # Temporary storage
```

**Use cases:**
- Temporary cache
- Scratch space
- Data sharing between containers in same pod

### 2. hostPath (Node Storage)

Mounts file or directory from host node.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: host-data
      mountPath: /data
  volumes:
  - name: host-data
    hostPath:
      path: /mnt/data
      type: DirectoryOrCreate
```

**⚠️ Warning:** Pod rescheduled to different node loses data.

### 3. Persistent Volumes (Production)

For persistent storage that survives pod restarts and rescheduling.

## Persistent Volumes (PV)

### What is a PV?

A **Persistent Volume** is a piece of storage in the cluster provisioned by an administrator or dynamically.

### PV Example

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: slow
  nfs:
    server: nfs-server.example.com
    path: /exports
```

### Access Modes

- **ReadWriteOnce (RWO)**: Single node read-write
- **ReadOnlyMany (ROX)**: Multiple nodes read-only
- **ReadWriteMany (RWX)**: Multiple nodes read-write

### Reclaim Policies

- **Retain**: Manual cleanup after release
- **Delete**: Delete storage when PVC deleted
- **Recycle**: Basic scrub (deprecated)

## Persistent Volume Claims (PVC)

### What is a PVC?

A **Persistent Volume Claim** is a request for storage by a user.

### PVC Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: fast
```

### Using PVC in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: password
    volumeMounts:
    - name: mysql-storage
      mountPath: /var/lib/mysql
  volumes:
  - name: mysql-storage
    persistentVolumeClaim:
      claimName: mysql-pvc
```

## Storage Classes

### What is a StorageClass?

**StorageClass** enables dynamic provisioning of PVs.

### StorageClass Example

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
```

### Common Provisioners

- **AWS**: `kubernetes.io/aws-ebs`
- **GCP**: `kubernetes.io/gce-pd`
- **Azure**: `kubernetes.io/azure-disk`
- **Local**: `kubernetes.io/no-provisioner`
- **NFS**: External provisioner

### Volume Binding Modes

- **Immediate**: Provision volume when PVC created
- **WaitForFirstConsumer**: Wait until pod using PVC is scheduled

## Complete Example: WordPress with MySQL

```yaml
# MySQL PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
---
# MySQL Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate  # Can't have multiple writers
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        - name: MYSQL_DATABASE
          value: wordpress
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
---
# WordPress PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wordpress-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
---
# WordPress Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql
        - name: WORDPRESS_DB_PASSWORD
          value: rootpassword
        ports:
        - containerPort: 80
        volumeMounts:
        - name: wordpress-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-storage
        persistentVolumeClaim:
          claimName: wordpress-pvc
```

## Hands-On Labs

### Lab 1: emptyDir Volume

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-test
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sh", "-c", "while true; do echo \$(date) >> /cache/log.txt; sleep 5; done"]
    volumeMounts:
    - name: cache
      mountPath: /cache
  - name: reader
    image: busybox
    command: ["sh", "-c", "tail -f /cache/log.txt"]
    volumeMounts:
    - name: cache
      mountPath: /cache
  volumes:
  - name: cache
    emptyDir: {}
EOF

# View logs from reader
kubectl logs emptydir-test -c reader

# Delete pod (emptyDir data lost)
kubectl delete pod emptydir-test
```

### Lab 2: PVC and Storage

```bash
# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Check PVC status
kubectl get pvc test-pvc

# Create pod using PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: test-pvc
EOF

# Write data
kubectl exec pvc-pod -- sh -c "echo 'Hello from PVC' > /usr/share/nginx/html/index.html"

# Delete and recreate pod
kubectl delete pod pvc-pod
kubectl apply -f pvc-pod.yaml

# Data persists
kubectl exec pvc-pod -- cat /usr/share/nginx/html/index.html
```

### Lab 3: MySQL with Persistence

```bash
# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
EOF

# Deploy MySQL
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        - name: MYSQL_DATABASE
          value: testdb
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc
EOF

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql --timeout=120s

# Create test data
kubectl exec -it deployment/mysql -- mysql -ppassword -e "USE testdb; CREATE TABLE test (id INT, data VARCHAR(50)); INSERT INTO test VALUES (1, 'persistent data');"

# Delete and recreate deployment
kubectl delete deployment mysql
kubectl apply -f mysql-deployment.yaml

# Data persists
kubectl exec -it deployment/mysql -- mysql -ppassword -e "USE testdb; SELECT * FROM test;"
```

## Best Practices

1. **Use PVCs for stateful apps** - Databases, file uploads
2. **Set resource requests** - Storage size in PVC
3. **Choose correct access mode** - RWO for most apps, RWX for shared storage
4. **Use StorageClass** - For dynamic provisioning
5. **Set reclaim policy** - Retain for important data
6. **Enable volume expansion** - For growing storage needs
7. **Backup important data** - PVs can still fail

## Storage Comparison

| Type | Persistence | Shared | Use Case |
|------|-------------|--------|----------|
| emptyDir | No | Pod only | Cache, scratch |
| hostPath | Node-local | No | Node-specific data |
| PV/PVC | Yes | Depends on access mode | Databases, files |

## Key Takeaways

- **emptyDir**: Temporary pod storage
- **hostPath**: Node-specific storage
- **PV**: Cluster storage resource
- **PVC**: Storage request by user
- **StorageClass**: Dynamic provisioning
- **Access modes**: RWO, ROX, RWX
- **Reclaim policy**: Retain vs Delete

## Next Steps

- **[Module 17: StatefulSets](17-statefulsets.md)**
- Practice with examples in `examples/storage/`

## Additional Resources

- [Kubernetes Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
