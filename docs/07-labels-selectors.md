# Module 7: Labels & Selectors

## Overview

Labels and selectors are fundamental Kubernetes concepts used to organize, select, and operate on groups of objects. They enable flexible resource management and are used extensively throughout Kubernetes.

## Learning Objectives

By the end of this module, you will be able to:
- Understand what labels and annotations are
- Create and manage labels on Kubernetes resources
- Use selectors to query and filter resources
- Apply labels for organizational purposes
- Understand best practices for labeling strategies

## Table of Contents

1. [What are Labels?](#what-are-labels)
2. [Label Syntax and Rules](#label-syntax-and-rules)
3. [Working with Labels](#working-with-labels)
4. [Selectors](#selectors)
5. [Annotations](#annotations)
6. [Best Practices](#best-practices)
7. [Hands-On Labs](#hands-on-labs)

---

## What are Labels?

### Definition

**Labels** are key-value pairs attached to Kubernetes objects (pods, services, deployments, etc.). They are used to organize and select subsets of objects.

### Why Labels Matter

Labels are essential for:
- **Organization**: Group related resources
- **Selection**: Filter resources for operations
- **Service Discovery**: Services use labels to find pods
- **Resource Management**: Controllers use labels to manage resources

### Real-World Example

Imagine a large organization with hundreds of applications:

```
Without Labels:
- 500 pods running
- Which ones are production?
- Which belong to the frontend team?
- Which need urgent updates?
→ Hard to manage!

With Labels:
- app=frontend, environment=production
- app=backend, environment=staging
- team=platform, priority=high
→ Easy to find and manage!
```

### Label Structure

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  labels:
    app: frontend           # Application name
    environment: production # Environment
    tier: web              # Application tier
    version: v1.2.0        # Version
    team: platform         # Owning team
```

---

## Label Syntax and Rules

### Valid Label Format

Labels consist of a **key** and a **value**.

**Key Format:**
- Optional prefix + name, separated by `/`
- Prefix (optional): DNS subdomain (max 253 characters)
- Name: Required, max 63 characters
- Allowed characters: alphanumeric, `-`, `_`, `.`
- Must start and end with alphanumeric

**Value Format:**
- Max 63 characters
- Allowed characters: alphanumeric, `-`, `_`, `.`
- Can be empty
- Must start and end with alphanumeric (if not empty)

### Examples

**✅ Valid Labels:**
```yaml
labels:
  app: nginx
  environment: production
  version: v1.0.0
  tier: frontend
  kubernetes.io/managed-by: helm
  app.kubernetes.io/name: mysql
  company.com/team: platform
```

**❌ Invalid Labels:**
```yaml
labels:
  App: nginx              # ❌ Capital letters not recommended
  "environment": prod     # ❌ Quotes not needed
  version: "v1.0.0"       # ❌ Quotes not needed
  tier-: frontend         # ❌ Can't end with dash
  -tier: frontend         # ❌ Can't start with dash
```

### Reserved Prefixes

Kubernetes reserves the `kubernetes.io/` and `k8s.io/` prefixes for core components:

```yaml
labels:
  kubernetes.io/hostname: node-1
  kubernetes.io/os: linux
  k8s.io/cluster-service: "true"
```

**For your own labels, either:**
- Use no prefix: `app: frontend`
- Use your domain: `mycompany.com/team: platform`

---

## Working with Labels

### Adding Labels at Creation

**Method 1: In YAML**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: labeled-pod
  labels:
    app: nginx
    environment: production
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:1.21
```

**Method 2: Using kubectl**
```bash
# Create pod with labels
kubectl run nginx --image=nginx --labels="app=nginx,env=prod"

# Create deployment with labels
kubectl create deployment webapp --image=nginx --replicas=3
kubectl label deployment webapp environment=production tier=frontend
```

### Viewing Labels

```bash
# Show labels in columns
kubectl get pods --show-labels

# Output:
# NAME    READY   STATUS    LABELS
# pod-1   1/1     Running   app=nginx,env=prod

# Show specific label as column
kubectl get pods -L app,environment

# Output:
# NAME    READY   STATUS    APP     ENVIRONMENT
# pod-1   1/1     Running   nginx   production

# View labels in describe
kubectl describe pod my-pod | grep Labels
```

### Adding Labels to Existing Resources

```bash
# Add single label
kubectl label pod my-pod tier=frontend

# Add multiple labels
kubectl label pod my-pod app=nginx environment=production

# Add label to all pods
kubectl label pods --all environment=production
```

### Updating Labels

```bash
# Update label (requires --overwrite)
kubectl label pod my-pod environment=staging --overwrite

# Without --overwrite, you'll get an error if label exists
```

### Removing Labels

```bash
# Remove label (use minus sign)
kubectl label pod my-pod tier-

# Remove multiple labels
kubectl label pod my-pod app- environment-
```

---

## Selectors

### What are Selectors?

**Selectors** allow you to filter and select Kubernetes objects based on their labels.

### Types of Selectors

#### 1. Equality-Based Selectors

Uses `=`, `==`, or `!=` operators.

**In kubectl:**
```bash
# Select pods with app=nginx
kubectl get pods -l app=nginx

# Select pods where environment is NOT production
kubectl get pods -l environment!=production

# Multiple conditions (AND logic)
kubectl get pods -l app=nginx,environment=production
```

**In YAML:**
```yaml
selector:
  matchLabels:
    app: nginx
    environment: production
```

#### 2. Set-Based Selectors

Uses `in`, `notin`, and `exists` operators.

**In kubectl:**
```bash
# Pods where environment is prod or staging
kubectl get pods -l 'environment in (production,staging)'

# Pods where tier is not frontend or backend
kubectl get pods -l 'tier notin (frontend,backend)'

# Pods that have the 'app' label (any value)
kubectl get pods -l 'app'

# Pods that don't have the 'environment' label
kubectl get pods -l '!environment'
```

**In YAML:**
```yaml
selector:
  matchExpressions:
  - key: environment
    operator: In
    values:
    - production
    - staging
  - key: tier
    operator: NotIn
    values:
    - deprecated
```

### Selectors in Action

#### Service Selecting Pods

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend        # Selects all pods with app=frontend
    environment: production
  ports:
  - port: 80
    targetPort: 8080
```

#### Deployment Managing Pods

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  selector:
    matchLabels:
      app: webapp        # Must match template labels
  template:
    metadata:
      labels:
        app: webapp      # These labels must match selector
        tier: frontend
    spec:
      containers:
      - name: app
        image: nginx
```

### Selector Examples

```bash
# Get all production pods
kubectl get pods -l environment=production

# Get all frontend pods in production
kubectl get pods -l app=frontend,environment=production

# Get all pods owned by platform team
kubectl get pods -l team=platform

# Get all pods except those in development
kubectl get pods -l environment!=development

# Get pods in production or staging
kubectl get pods -l 'environment in (production,staging)'

# Delete all test pods
kubectl delete pods -l environment=test

# Scale all frontend deployments
kubectl scale deployment -l app=frontend --replicas=3
```

---

## Annotations

### What are Annotations?

**Annotations** are also key-value pairs, but unlike labels, they're not used for selection. They store non-identifying metadata.

### Labels vs Annotations

| Feature | Labels | Annotations |
|---------|--------|-------------|
| Purpose | Identify and select resources | Store metadata |
| Used by selectors | ✅ Yes | ❌ No |
| Size limit | 63 characters | 256 KB |
| Used for grouping | ✅ Yes | ❌ No |
| Examples | app, environment, version | build info, contact details |

### When to Use Annotations

Use annotations for:
- Build/release information
- Contact information
- Timestamps
- Tool-specific configuration
- Change tracking
- Documentation links

### Annotation Examples

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: annotated-pod
  labels:
    app: webapp
  annotations:
    # Build information
    build.version: "1.2.3"
    build.timestamp: "2024-01-15T10:30:00Z"
    build.commit: "abc123def456"
    
    # Contact information
    owner: "platform-team@company.com"
    slack-channel: "#platform-alerts"
    
    # Documentation
    documentation: "https://docs.company.com/webapp"
    
    # Change tracking
    kubernetes.io/change-cause: "Updated to fix security vulnerability"
    
    # Tool-specific
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
spec:
  containers:
  - name: webapp
    image: webapp:1.2.3
```

### Working with Annotations

```bash
# Add annotation
kubectl annotate pod my-pod owner="team@company.com"

# View annotations
kubectl describe pod my-pod | grep Annotations

# Update annotation
kubectl annotate pod my-pod owner="newteam@company.com" --overwrite

# Remove annotation
kubectl annotate pod my-pod owner-
```

---

## Best Practices

### 1. Use Meaningful Label Names

```yaml
# ✅ Good - Clear and descriptive
labels:
  app: frontend
  environment: production
  tier: web
  version: v1.2.0

# ❌ Bad - Unclear
labels:
  l1: fe
  env: prod
  t: w
```

### 2. Use Recommended Labels

Kubernetes recommends these standard labels:

```yaml
labels:
  app.kubernetes.io/name: mysql
  app.kubernetes.io/instance: mysql-abcxzy
  app.kubernetes.io/version: "5.7.21"
  app.kubernetes.io/component: database
  app.kubernetes.io/part-of: wordpress
  app.kubernetes.io/managed-by: helm
```

### 3. Consistent Naming Convention

Choose a convention and stick to it:

```yaml
# ✅ Good - Consistent lowercase with hyphens
labels:
  app: my-app
  environment: production
  tier: frontend

# ❌ Mixed - Inconsistent
labels:
  App: MyApp
  ENVIRONMENT: prod
  tier_name: Frontend
```

### 4. Include Essential Labels

Every resource should have at least:

```yaml
labels:
  app: <application-name>      # What application
  environment: <env>           # Which environment
  version: <version>           # Which version
```

### 5. Use Labels for Organization

```yaml
# Team ownership
labels:
  team: platform
  owner: devops-team

# Cost tracking
labels:
  cost-center: engineering
  project: customer-portal

# Lifecycle
labels:
  lifecycle: permanent
  criticality: high
```

### 6. Don't Overuse Labels

```yaml
# ✅ Good - Essential labels only
labels:
  app: frontend
  environment: production
  tier: web

# ❌ Bad - Too many labels
labels:
  app: frontend
  environment: production
  tier: web
  created-by: john
  created-date: 2024-01-15
  last-modified: 2024-01-20
  git-commit: abc123
  # Use annotations for this metadata instead!
```

### 7. Plan for Querying

Think about how you'll select resources:

```bash
# If you need to select all frontend apps:
kubectl get pods -l tier=frontend

# If you need all production resources:
kubectl get all -l environment=production

# If you need specific team resources:
kubectl get all -l team=platform
```

---

## Hands-On Labs

### Lab 1: Create Resources with Labels

**Objective:** Practice creating resources with labels

**Steps:**

1. Create a pod with labels:
```bash
kubectl run webapp --image=nginx \
  --labels="app=webapp,tier=frontend,environment=production"
```

2. Verify labels:
```bash
kubectl get pods --show-labels
```

3. View specific labels as columns:
```bash
kubectl get pods -L app,tier,environment
```

4. Create deployment with labels:
```yaml
# webapp-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  labels:
    app: webapp
    team: platform
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        tier: frontend
        version: v1.0.0
    spec:
      containers:
      - name: webapp
        image: nginx:1.21
```

5. Apply:
```bash
kubectl apply -f webapp-deployment.yaml
```

6. View all labels:
```bash
kubectl get pods --show-labels
```

### Lab 2: Add and Update Labels

**Objective:** Practice modifying labels

**Steps:**

1. List current pods:
```bash
kubectl get pods --show-labels
```

2. Add a label to a pod:
```bash
kubectl label pod <pod-name> owner=platform-team
```

3. Verify:
```bash
kubectl get pod <pod-name> --show-labels
```

4. Update a label:
```bash
kubectl label pod <pod-name> tier=backend --overwrite
```

5. Add label to all pods:
```bash
kubectl label pods --all environment=production
```

6. Verify:
```bash
kubectl get pods --show-labels
```

### Lab 3: Use Selectors

**Objective:** Practice selecting resources with labels

**Steps:**

1. Create multiple pods with different labels:
```bash
kubectl run frontend-1 --image=nginx --labels="app=frontend,env=prod"
kubectl run frontend-2 --image=nginx --labels="app=frontend,env=staging"
kubectl run backend-1 --image=nginx --labels="app=backend,env=prod"
kubectl run backend-2 --image=nginx --labels="app=backend,env=staging"
```

2. Select all frontend pods:
```bash
kubectl get pods -l app=frontend
```

3. Select all production pods:
```bash
kubectl get pods -l env=prod
```

4. Select frontend production pods:
```bash
kubectl get pods -l app=frontend,env=prod
```

5. Select staging pods:
```bash
kubectl get pods -l env=staging
```

6. Select pods that are NOT frontend:
```bash
kubectl get pods -l app!=frontend
```

7. Select pods in prod or staging:
```bash
kubectl get pods -l 'env in (prod,staging)'
```

### Lab 4: Service Selection

**Objective:** Understand how services use labels

**Steps:**

1. Create pods with labels:
```bash
kubectl run web-1 --image=nginx --labels="app=web,version=v1"
kubectl run web-2 --image=nginx --labels="app=web,version=v1"
kubectl run web-3 --image=nginx --labels="app=web,version=v2"
```

2. Create service targeting v1 pods:
```yaml
# web-service-v1.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-v1
spec:
  selector:
    app: web
    version: v1
  ports:
  - port: 80
    targetPort: 80
```

3. Apply:
```bash
kubectl apply -f web-service-v1.yaml
```

4. Check endpoints (should show only v1 pods):
```bash
kubectl get endpoints web-service-v1
kubectl describe service web-service-v1
```

5. Change a pod's label:
```bash
# Move web-1 to v2
kubectl label pod web-1 version=v2 --overwrite
```

6. Check endpoints again:
```bash
kubectl describe service web-service-v1
# Should now show only web-2
```

### Lab 5: Bulk Operations with Selectors

**Objective:** Perform operations on multiple resources

**Steps:**

1. Create test environment:
```bash
kubectl create deployment test-app-1 --image=nginx --replicas=2
kubectl create deployment test-app-2 --image=nginx --replicas=2
kubectl label deployment test-app-1 environment=test
kubectl label deployment test-app-2 environment=test
```

2. List all test deployments:
```bash
kubectl get deployments -l environment=test
```

3. Scale all test deployments:
```bash
kubectl scale deployment -l environment=test --replicas=1
```

4. Verify:
```bash
kubectl get deployments -l environment=test
```

5. Delete all test deployments:
```bash
kubectl delete deployment -l environment=test
```

6. Verify deletion:
```bash
kubectl get deployments
```

### Lab 6: Annotations

**Objective:** Work with annotations

**Steps:**

1. Create a pod:
```bash
kubectl run annotated-pod --image=nginx
```

2. Add annotations:
```bash
kubectl annotate pod annotated-pod \
  owner="platform-team@company.com" \
  documentation="https://wiki.company.com/annotated-pod"
```

3. View annotations:
```bash
kubectl describe pod annotated-pod | grep Annotations -A 5
```

4. Update annotation:
```bash
kubectl annotate pod annotated-pod \
  owner="devops-team@company.com" --overwrite
```

5. Remove annotation:
```bash
kubectl annotate pod annotated-pod documentation-
```

### Lab 7: Cleanup

```bash
# Delete all resources created in labs
kubectl delete pods --all
kubectl delete deployments --all
kubectl delete services --all
```

---

## Common Commands Reference

### Label Operations

```bash
# Create with labels
kubectl run pod-name --image=nginx --labels="app=web,env=prod"

# Add label
kubectl label pod <name> key=value

# Add multiple labels
kubectl label pod <name> key1=value1 key2=value2

# Update label
kubectl label pod <name> key=value --overwrite

# Remove label
kubectl label pod <name> key-

# Label all pods
kubectl label pods --all environment=production

# View labels
kubectl get pods --show-labels
kubectl get pods -L app,environment
```

### Selector Operations

```bash
# Equality-based
kubectl get pods -l app=nginx
kubectl get pods -l environment!=production
kubectl get pods -l app=nginx,tier=frontend

# Set-based
kubectl get pods -l 'environment in (prod,staging)'
kubectl get pods -l 'tier notin (frontend,backend)'
kubectl get pods -l app
kubectl get pods -l '!environment'

# Complex queries
kubectl get pods -l 'app=nginx,environment in (prod,staging)'
```

### Annotation Operations

```bash
# Add annotation
kubectl annotate pod <name> key=value

# Update annotation
kubectl annotate pod <name> key=value --overwrite

# Remove annotation
kubectl annotate pod <name> key-

# View annotations
kubectl describe pod <name> | grep Annotations
```

---

## Key Takeaways

1. **Labels identify and organize** - Use them for grouping and selecting resources
2. **Selectors filter resources** - Based on label queries
3. **Services use labels** - To find and route traffic to pods
4. **Controllers use labels** - Deployments, ReplicaSets use labels to manage pods
5. **Annotations store metadata** - For non-identifying information
6. **Consistent labeling is crucial** - Plan your labeling strategy
7. **Labels enable automation** - Bulk operations based on labels

---

## Next Steps

Now that you understand labels and selectors, you're ready for:
- **[Module 8: Services](08-services.md)** - Services use labels to select pods
- Practice with the example YAML files in `examples/labels/`
- Apply labeling strategies to your own applications

---

## Additional Resources

- [Kubernetes Official Docs - Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Recommended Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
- [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
- [kubectl Cheat Sheet](kubectl-cheatsheet.md)

---

**Congratulations!** You now understand how to organize and select Kubernetes resources using labels and selectors! 🎉
