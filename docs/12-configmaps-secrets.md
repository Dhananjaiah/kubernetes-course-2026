# Module 12: ConfigMaps & Secrets

## Overview

ConfigMaps and Secrets allow you to decouple configuration from container images, making applications more portable and secure.

## Learning Objectives

- Create and manage ConfigMaps
- Create and manage Secrets
- Use ConfigMaps and Secrets in pods
- Understand security best practices

## ConfigMaps

### What is a ConfigMap?

A **ConfigMap** stores non-confidential configuration data as key-value pairs.

### Creating ConfigMaps

**Method 1: From literal values**
```bash
kubectl create configmap app-config \
  --from-literal=database_host=mysql.example.com \
  --from-literal=database_port=3306 \
  --from-literal=app_env=production
```

**Method 2: From file**
```bash
# Create config file
echo "database_host=mysql.example.com" > config.properties
echo "database_port=3306" >> config.properties

kubectl create configmap app-config --from-file=config.properties
```

**Method 3: From YAML**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_host: "mysql.example.com"
  database_port: "3306"
  app_env: "production"
  
  # Can also store entire config files
  nginx.conf: |
    server {
      listen 80;
      server_name example.com;
      location / {
        proxy_pass http://backend:8080;
      }
    }
```

### Using ConfigMaps in Pods

**As Environment Variables:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    
    # Method 1: Individual keys as env vars
    env:
    - name: DATABASE_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_host
    
    # Method 2: All keys as env vars
    envFrom:
    - configMapRef:
        name: app-config
```

**As Volume Mounts:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx:1.21
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
      
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

## Secrets

### What is a Secret?

A **Secret** stores sensitive data like passwords, tokens, and keys. Data is base64-encoded (not encrypted by default).

### Secret Types

- **Opaque**: Generic secret (default)
- **kubernetes.io/service-account-token**: Service account token
- **kubernetes.io/dockerconfigjson**: Docker registry credentials
- **kubernetes.io/tls**: TLS certificate and key

### Creating Secrets

**Method 1: From literal values**
```bash
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=secretpassword
```

**Method 2: From files**
```bash
echo -n 'admin' > username.txt
echo -n 'secretpassword' > password.txt

kubectl create secret generic db-secret \
  --from-file=username.txt \
  --from-file=password.txt
```

**Method 3: From YAML**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  # Values must be base64 encoded
  username: YWRtaW4=        # admin
  password: c2VjcmV0cGFzc3dvcmQ=  # secretpassword
  
# Or use stringData (auto-encodes to base64)
stringData:
  username: admin
  password: secretpassword
```

### Using Secrets in Pods

**As Environment Variables:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
```

**As Volume Mounts:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
      
  volumes:
  - name: secret-volume
    secret:
      secretName: db-secret
```

### Docker Registry Secret

```bash
# Create docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=password \
  --docker-email=user@example.com

# Use in pod
apiVersion: v1
kind: Pod
metadata:
  name: private-pod
spec:
  containers:
  - name: app
    image: registry.example.com/myapp:1.0
  imagePullSecrets:
  - name: regcred
```

### TLS Secret

```bash
# Create TLS secret
kubectl create secret tls tls-secret \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key

# Use in Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
```

## Hands-On Labs

### Lab 1: ConfigMap Basics

```bash
# Create ConfigMap
kubectl create configmap game-config \
  --from-literal=player_initial_lives=3 \
  --from-literal=ui_properties_file_name=user-interface.properties

# View ConfigMap
kubectl get configmap game-config
kubectl describe configmap game-config

# View as YAML
kubectl get configmap game-config -o yaml

# Use in pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: game-pod
spec:
  containers:
  - name: game
    image: busybox
    command: ["sh", "-c", "env && sleep 3600"]
    envFrom:
    - configMapRef:
        name: game-config
EOF

# Verify env vars
kubectl exec game-pod -- env | grep -E "player|ui"
```

### Lab 2: ConfigMap from File

```bash
# Create config file
cat > app.properties << EOF
database.host=mysql.example.com
database.port=3306
database.name=myapp
cache.enabled=true
cache.ttl=300
EOF

# Create ConfigMap from file
kubectl create configmap app-properties --from-file=app.properties

# Mount as volume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "cat /config/app.properties && sleep 3600"]
    volumeMounts:
    - name: config
      mountPath: /config
  volumes:
  - name: config
    configMap:
      name: app-properties
EOF

# Verify file content
kubectl logs config-pod
```

### Lab 3: Secrets

```bash
# Create secret
kubectl create secret generic db-credentials \
  --from-literal=username=dbuser \
  --from-literal=password=SuperSecret123

# View secret (values hidden)
kubectl get secret db-credentials
kubectl describe secret db-credentials

# View encoded values
kubectl get secret db-credentials -o yaml

# Decode value
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 -d

# Use in pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo Username: \$DB_USER, Password: \$DB_PASS && sleep 3600"]
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
EOF

# Verify (be careful in production!)
kubectl logs db-pod
```

### Lab 4: Update ConfigMap/Secret

```bash
# Update ConfigMap
kubectl create configmap dynamic-config --from-literal=color=blue -o yaml --dry-run=client | kubectl apply -f -

# Create pod using it
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "while true; do cat /config/color; sleep 5; done"]
    volumeMounts:
    - name: config
      mountPath: /config
  volumes:
  - name: config
    configMap:
      name: dynamic-config
EOF

# Watch logs
kubectl logs -f dynamic-pod

# Update ConfigMap (in another terminal)
kubectl create configmap dynamic-config --from-literal=color=red -o yaml --dry-run=client | kubectl apply -f -

# ConfigMap updates automatically propagate to mounted volumes (may take up to a minute)
```

## Security Best Practices

### 1. Use RBAC to Control Access

```yaml
# Limit who can view/edit secrets
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

### 2. Enable Encryption at Rest

```bash
# Configure API server with encryption provider
# /etc/kubernetes/manifests/kube-apiserver.yaml
--encryption-provider-config=/path/to/encryption-config.yaml
```

### 3. Use External Secret Management

- **Sealed Secrets**: Encrypted secrets in Git
- **External Secrets Operator**: Sync from Vault, AWS Secrets Manager
- **HashiCorp Vault**: Centralized secret management

### 4. Never Commit Secrets to Git

```bash
# Use .gitignore
echo "secrets/" >> .gitignore
echo "*.secret" >> .gitignore
```

### 5. Use Secret Scanning Tools

- git-secrets
- truffleHog
- GitHub secret scanning

### 6. Rotate Secrets Regularly

```bash
# Update secret
kubectl create secret generic db-secret \
  --from-literal=password=NewPassword123 \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to pick up new secret
kubectl rollout restart deployment/my-app
```

## Common Commands

```bash
# ConfigMaps
kubectl create configmap <name> --from-literal=key=value
kubectl create configmap <name> --from-file=file
kubectl get configmaps
kubectl describe configmap <name>
kubectl delete configmap <name>

# Secrets
kubectl create secret generic <name> --from-literal=key=value
kubectl create secret generic <name> --from-file=file
kubectl get secrets
kubectl describe secret <name>
kubectl delete secret <name>

# View secret data (base64 encoded)
kubectl get secret <name> -o yaml

# Decode secret
kubectl get secret <name> -o jsonpath='{.data.key}' | base64 -d
```

## Key Takeaways

1. **ConfigMaps for configuration** - Non-sensitive data
2. **Secrets for sensitive data** - Passwords, tokens, keys
3. **base64 is encoding, not encryption** - Use encryption at rest
4. **Use RBAC** - Control access to secrets
5. **External secret management** - For production
6. **Rotate secrets regularly** - Security best practice
7. **Volume mounts auto-update** - Env vars don't update automatically

## Next Steps

- **[Module 13: Health Probes](13-health-probes.md)**
- Practice with examples in `examples/configmaps/` and `examples/secrets/`

## Additional Resources

- [Kubernetes ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Encrypting Secret Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)
