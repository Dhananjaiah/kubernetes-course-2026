# Module 18: RBAC (Role-Based Access Control)

## Overview

RBAC (Role-Based Access Control) controls who can access what resources in your Kubernetes cluster. It's essential for security and multi-tenancy.

## Learning Objectives

- Understand RBAC components
- Create Roles and RoleBindings
- Create ClusterRoles and ClusterRoleBindings
- Manage ServiceAccounts
- Implement least privilege access

## RBAC Components

### 1. Role & ClusterRole

**Role**: Namespaced permissions
**ClusterRole**: Cluster-wide permissions

### 2. RoleBinding & ClusterRoleBinding

**RoleBinding**: Binds Role to users/groups in a namespace
**ClusterRoleBinding**: Binds ClusterRole cluster-wide

### 3. ServiceAccount

Identity for pods to access Kubernetes API.

## RBAC Model

```
Subject (Who)           Verb (Action)        Resource (What)
─────────────          ─────────────        ───────────────
User                   get                  pods
Group                  list                 services
ServiceAccount         create               deployments
                       update               configmaps
                       delete               secrets
                       watch                events
```

## Role Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: pod-reader
rules:
- apiGroups: [""]  # "" indicates core API group
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
```

## RoleBinding Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: development
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
- kind: ServiceAccount
  name: my-app
  namespace: development
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

## ClusterRole Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
```

## ClusterRoleBinding Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: security-team
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

## ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-serviceaccount
  namespace: production
---
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: production
spec:
  serviceAccountName: app-serviceaccount
  containers:
  - name: app
    image: myapp:1.0
```

## Common RBAC Patterns

### Pattern 1: Read-Only User

```yaml
# Role: View pods and services
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: viewer
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "services", "deployments"]
  verbs: ["get", "list", "watch"]
---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: viewer-binding
  namespace: default
subjects:
- kind: User
  name: readonly-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: viewer
  apiGroup: rbac.authorization.k8s.io
```

### Pattern 2: Developer Access

```yaml
# ClusterRole: Full access to most resources, no cluster admin
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer
rules:
- apiGroups: ["", "apps", "batch"]
  resources: ["pods", "services", "deployments", "jobs", "cronjobs"]
  verbs: ["*"]
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "create", "update"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
---
# ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developer-binding
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

### Pattern 3: CI/CD ServiceAccount

```yaml
# ServiceAccount for CI/CD
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cicd
  namespace: production
---
# Role: Deploy applications
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: deployer
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["services", "configmaps"]
  verbs: ["get", "list", "create", "update"]
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
---
# RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cicd-deployer
  namespace: production
subjects:
- kind: ServiceAccount
  name: cicd
  namespace: production
roleRef:
  kind: Role
  name: deployer
  apiGroup: rbac.authorization.k8s.io
```

## Verbs (Actions)

```
get         - Get individual resource
list        - List resources
watch       - Watch for changes
create      - Create new resources
update      - Update existing resources
patch       - Patch resources
delete      - Delete resources
deletecollection - Delete multiple resources

Special:
*           - All verbs
```

## API Groups

```
""          - Core API group (pods, services, configmaps)
apps        - Deployments, StatefulSets, DaemonSets
batch       - Jobs, CronJobs
rbac.authorization.k8s.io - RBAC resources
networking.k8s.io - Network policies, Ingress
storage.k8s.io - StorageClasses, VolumeAttachments
```

## Resource Names (Fine-Grained Control)

```yaml
# Allow access only to specific resources
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: limited-access
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["app-config", "db-config"]  # Only these ConfigMaps
  verbs: ["get", "update"]
```

## Hands-On Labs

### Lab 1: Create ServiceAccount and Role

```bash
# Create namespace
kubectl create namespace dev

# Create ServiceAccount
kubectl create serviceaccount dev-user -n dev

# Create Role
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "delete"]
EOF

# Create RoleBinding
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-pod-manager
  namespace: dev
subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
EOF

# Test permissions
kubectl auth can-i list pods --as=system:serviceaccount:dev:dev-user -n dev
kubectl auth can-i delete deployments --as=system:serviceaccount:dev:dev-user -n dev
```

### Lab 2: ClusterRole for Monitoring

```bash
# Create ClusterRole
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-monitor
rules:
- apiGroups: [""]
  resources: ["nodes", "pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "daemonsets", "statefulsets"]
  verbs: ["get", "list", "watch"]
EOF

# Create ServiceAccount
kubectl create serviceaccount monitor -n kube-system

# Create ClusterRoleBinding
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitor-binding
subjects:
- kind: ServiceAccount
  name: monitor
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-monitor
  apiGroup: rbac.authorization.k8s.io
EOF

# Test
kubectl auth can-i list nodes --as=system:serviceaccount:kube-system:monitor
```

### Lab 3: Pod with ServiceAccount

```bash
# Create ServiceAccount and Role
kubectl create serviceaccount app-sa
kubectl create role app-role --verb=get,list --resource=configmaps
kubectl create rolebinding app-rb --role=app-role --serviceaccount=default:app-sa

# Create pod with ServiceAccount
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
EOF

# Test from within pod
kubectl exec app-pod -- sh -c "
  TOKEN=\$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  curl -H \"Authorization: Bearer \$TOKEN\" -k https://kubernetes.default.svc/api/v1/namespaces/default/configmaps
"
```

## Testing Permissions

```bash
# Check if you can perform action
kubectl auth can-i create deployments
kubectl auth can-i delete pods -n production

# Check for another user
kubectl auth can-i list secrets --as=jane
kubectl auth can-i delete pods --as=system:serviceaccount:default:my-app

# List all permissions for current user
kubectl auth can-i --list

# List all permissions in namespace
kubectl auth can-i --list --namespace=production
```

## Built-in ClusterRoles

```bash
# View built-in ClusterRoles
kubectl get clusterroles

# Common built-in roles:
cluster-admin    - Full cluster access
admin            - Full namespace access
edit             - Edit resources in namespace
view             - Read-only access
```

### Using Built-in Roles

```bash
# Give user admin access to namespace
kubectl create rolebinding admin-binding \
  --clusterrole=admin \
  --user=jane \
  --namespace=production

# Give user view-only access cluster-wide
kubectl create clusterrolebinding view-binding \
  --clusterrole=view \
  --user=john
```

## Best Practices

1. **Principle of least privilege** - Give minimum required permissions
2. **Use namespaced Roles** - Prefer Role over ClusterRole when possible
3. **Avoid wildcard permissions** - Be specific with verbs and resources
4. **Use ServiceAccounts for pods** - Don't use default ServiceAccount
5. **Regular audits** - Review and clean up unused permissions
6. **Separate admin access** - Don't give cluster-admin to everyone
7. **Test permissions** - Use `kubectl auth can-i`

## Security Tips

### ❌ Don't Do This

```yaml
# Too permissive
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

### ✅ Do This Instead

```yaml
# Specific permissions
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "update"]
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
```

## Troubleshooting

### Forbidden Error

```bash
# Error: User cannot list pods
# Solution: Check permissions
kubectl auth can-i list pods --as=jane

# Check what user can do
kubectl auth can-i --list --as=jane

# View role/rolebinding
kubectl get role,rolebinding
kubectl describe role <role-name>
kubectl describe rolebinding <binding-name>
```

## Key Takeaways

- **RBAC controls access** - Who can do what
- **Role vs ClusterRole** - Namespaced vs cluster-wide
- **RoleBinding vs ClusterRoleBinding** - Grants permissions
- **ServiceAccount for pods** - Pod identity
- **Least privilege** - Give minimum required permissions
- **Test with `auth can-i`** - Verify permissions
- **Use built-in roles** - cluster-admin, admin, edit, view

## Next Steps

- **[Module 19: Ingress](19-ingress.md)**
- Practice with examples in `examples/rbac/`

## Additional Resources

- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
