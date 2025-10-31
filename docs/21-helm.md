# Module 21: Helm - Kubernetes Package Manager

## Overview

Helm is the package manager for Kubernetes. It simplifies deploying, upgrading, and managing applications using pre-configured templates called Charts.

## Learning Objectives

- Understand what Helm is and why it's useful
- Install and configure Helm
- Use Helm charts from repositories
- Create custom Helm charts
- Manage releases and perform rollbacks

## Why Helm?

### Without Helm

```
Multiple YAML files to manage:
- deployment.yaml
- service.yaml
- configmap.yaml
- ingress.yaml
- secret.yaml

Hard to:
- Version applications
- Share configurations
- Parameterize deployments
- Rollback changes
```

### With Helm

```
One command to:
- Install complete applications
- Customize with values
- Upgrade versions
- Rollback easily
- Share with others
```

## Helm Concepts

### Chart

A Helm **Chart** is a package containing:
- Kubernetes YAML templates
- Chart.yaml (metadata)
- values.yaml (default configuration)
- templates/ directory

### Release

A **Release** is an instance of a chart deployed to cluster.

### Repository

A **Repository** is a collection of charts (like npm registry, Docker Hub).

## Installing Helm

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows
choco install kubernetes-helm

# Verify installation
helm version
```

## Basic Helm Commands

### Add Repository

```bash
# Add official Helm stable repo
helm repo add stable https://charts.helm.sh/stable

# Add Bitnami repo (popular charts)
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# List repositories
helm repo list
```

### Search Charts

```bash
# Search in all repos
helm search repo nginx

# Search Helm Hub
helm search hub wordpress
```

### Install Chart

```bash
# Install nginx
helm install my-nginx bitnami/nginx

# Install with custom namespace
helm install my-nginx bitnami/nginx --namespace web --create-namespace

# Install with custom values
helm install my-nginx bitnami/nginx --set service.type=NodePort

# Install with values file
helm install my-nginx bitnami/nginx -f custom-values.yaml

# Dry run (see what would be created)
helm install my-nginx bitnami/nginx --dry-run --debug
```

### List Releases

```bash
# List releases in current namespace
helm list

# List all releases in all namespaces
helm list --all-namespaces

# List releases in specific namespace
helm list -n production
```

### Upgrade Release

```bash
# Upgrade release
helm upgrade my-nginx bitnami/nginx

# Upgrade with new values
helm upgrade my-nginx bitnami/nginx --set replicaCount=3

# Upgrade or install if doesn't exist
helm upgrade --install my-nginx bitnami/nginx
```

### Rollback Release

```bash
# View release history
helm history my-nginx

# Rollback to previous version
helm rollback my-nginx

# Rollback to specific revision
helm rollback my-nginx 2
```

### Uninstall Release

```bash
# Uninstall release
helm uninstall my-nginx

# Uninstall but keep history
helm uninstall my-nginx --keep-history
```

### Get Release Information

```bash
# Get values used in release
helm get values my-nginx

# Get all values (including defaults)
helm get values my-nginx --all

# Get manifest
helm get manifest my-nginx

# Get release notes
helm get notes my-nginx
```

## Creating Custom Charts

### Create Chart Structure

```bash
# Create new chart
helm create myapp

# Chart structure:
myapp/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── charts/            # Dependency charts
└── templates/         # Kubernetes templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── _helpers.tpl   # Template helpers
    └── NOTES.txt      # Release notes
```

### Chart.yaml

```yaml
apiVersion: v2
name: myapp
description: My Application Helm Chart
version: 1.0.0          # Chart version
appVersion: "1.0"       # Application version

keywords:
  - application
  - web

maintainers:
  - name: Your Name
    email: you@example.com

dependencies:
  - name: postgresql
    version: "12.1.0"
    repository: "https://charts.bitnami.com/bitnami"
```

### values.yaml

```yaml
replicaCount: 2

image:
  repository: myapp
  tag: "1.0.0"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### templates/deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        resources:
          {{- toYaml .Values.resources | nindent 12 }}
```

### templates/service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "myapp.selectorLabels" . | nindent 4 }}
```

## Helm Template Functions

```yaml
# Built-in Go templates
{{ .Values.replicaCount }}           # Access value
{{ .Release.Name }}                  # Release name
{{ .Chart.Name }}                    # Chart name
{{ .Chart.Version }}                 # Chart version

# Helm functions
{{ default "value" .Values.optional }}     # Default value
{{ quote .Values.name }}                   # Add quotes
{{ upper .Values.name }}                   # Uppercase
{{ lower .Values.name }}                   # Lowercase
{{ toYaml .Values.resources }}             # YAML format
{{ toJson .Values.data }}                  # JSON format
{{ include "myapp.labels" . }}             # Include template

# Conditionals
{{- if .Values.ingress.enabled }}
  # Ingress configuration
{{- end }}

# Loops
{{- range .Values.hosts }}
- host: {{ . }}
{{- end }}
```

## Using Custom Charts

```bash
# Validate chart
helm lint myapp/

# Template chart (see output)
helm template myapp ./myapp

# Install chart
helm install myapp-release ./myapp

# Install with custom values
helm install myapp-release ./myapp -f production-values.yaml

# Upgrade chart
helm upgrade myapp-release ./myapp

# Package chart
helm package myapp/
# Creates: myapp-1.0.0.tgz
```

## Complete Example: WordPress Chart

```bash
# Add Bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create custom values
cat > wordpress-values.yaml <<EOF
wordpressUsername: admin
wordpressPassword: SecurePassword123
wordpressEmail: admin@example.com
wordpressBlogName: My Awesome Blog

service:
  type: LoadBalancer

persistence:
  enabled: true
  size: 10Gi

mariadb:
  auth:
    rootPassword: RootPassword123
    database: wordpress
  primary:
    persistence:
      enabled: true
      size: 8Gi
EOF

# Install WordPress
helm install my-wordpress bitnami/wordpress -f wordpress-values.yaml

# Get WordPress URL
kubectl get svc my-wordpress

# Get admin password (if not set)
kubectl get secret my-wordpress -o jsonpath='{.data.wordpress-password}' | base64 -d

# Upgrade WordPress
helm upgrade my-wordpress bitnami/wordpress --set replicaCount=2

# Rollback if needed
helm rollback my-wordpress

# Uninstall
helm uninstall my-wordpress
```

## Hands-On Labs

### Lab 1: Install Application with Helm

```bash
# Add repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Search for nginx
helm search repo nginx

# Install nginx
helm install my-nginx bitnami/nginx

# Check release
helm list
kubectl get all -l app.kubernetes.io/instance=my-nginx

# Get service
kubectl get svc my-nginx

# Upgrade replicas
helm upgrade my-nginx bitnami/nginx --set replicaCount=3

# View history
helm history my-nginx

# Rollback
helm rollback my-nginx 1

# Uninstall
helm uninstall my-nginx
```

### Lab 2: Create Custom Chart

```bash
# Create chart
helm create mywebapp

# Edit values.yaml
cat > mywebapp/values.yaml <<EOF
replicaCount: 2
image:
  repository: nginx
  tag: "1.21"
service:
  type: NodePort
  port: 80
EOF

# Validate chart
helm lint mywebapp/

# Test template
helm template mywebapp ./mywebapp

# Install chart
helm install mywebapp-release ./mywebapp

# Verify
kubectl get all -l app.kubernetes.io/name=mywebapp
```

### Lab 3: Use Chart Dependencies

```bash
# Create chart with dependency
helm create fullstack-app

# Edit Chart.yaml to add dependency
cat > fullstack-app/Chart.yaml <<EOF
apiVersion: v2
name: fullstack-app
version: 1.0.0
dependencies:
  - name: postgresql
    version: "12.1.0"
    repository: "https://charts.bitnami.com/bitnami"
EOF

# Update dependencies
helm dependency update fullstack-app/

# Install with dependencies
helm install fullstack fullstack-app/

# Check all resources
helm list
kubectl get all
```

## Best Practices

1. **Use version control** - Track chart changes in Git
2. **Pin chart versions** - Don't use `latest`
3. **Separate values files** - dev-values.yaml, prod-values.yaml
4. **Use .helmignore** - Exclude unnecessary files
5. **Document charts** - README.md and NOTES.txt
6. **Test charts** - `helm lint` and `helm template`
7. **Use semantic versioning** - For chart versions
8. **Namespace isolation** - Deploy to separate namespaces

## Helm vs kubectl

| Operation | kubectl | Helm |
|-----------|---------|------|
| Deploy | `kubectl apply -f *.yaml` | `helm install myapp` |
| Update | `kubectl apply -f *.yaml` | `helm upgrade myapp` |
| Rollback | Manual | `helm rollback myapp` |
| Version | Manual tracking | Automatic |
| Parameterization | Hard | Easy (values.yaml) |
| Share | Copy files | Chart repository |

## Troubleshooting

```bash
# Debug installation
helm install myapp ./myapp --dry-run --debug

# Check values
helm get values myapp

# View manifest
helm get manifest myapp

# Check status
helm status myapp

# View release history
helm history myapp

# Validate chart
helm lint myapp/

# Test template rendering
helm template myapp ./myapp
```

## Popular Helm Charts

- **Prometheus** - Monitoring
- **Grafana** - Visualization
- **Jenkins** - CI/CD
- **GitLab** - DevOps platform
- **Redis** - Cache
- **PostgreSQL** - Database
- **MongoDB** - Database
- **Elasticsearch** - Search
- **Kafka** - Messaging
- **Nginx Ingress** - Ingress controller

## Key Takeaways

- **Helm = package manager** - For Kubernetes applications
- **Charts = packages** - Reusable application definitions
- **Releases = instances** - Running charts in cluster
- **Values = configuration** - Customize chart behavior
- **Repositories = registries** - Share and discover charts
- **Easy upgrades and rollbacks** - Version management built-in
- **Template engine** - Parameterize Kubernetes manifests

## Next Steps

- Explore Helm Hub: https://artifacthub.io/
- Create your own charts for applications
- Set up private chart repository
- Integrate Helm with CI/CD pipelines

## Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Artifact Hub](https://artifacthub.io/) - Find Helm charts
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Bitnami Charts](https://github.com/bitnami/charts)

---

**Congratulations!** 🎉 You've completed all 21 modules of the Kubernetes Course 2026!

You now have comprehensive knowledge of:
- Container and Kubernetes fundamentals
- Workload management (Pods, Deployments, StatefulSets)
- Networking (Services, Ingress)
- Storage and persistence
- Configuration and secrets
- Security (RBAC, Network Policies)
- Advanced topics (Helm, monitoring, scaling)

**Next Steps:**
- Practice by deploying real applications
- Consider CKA/CKAD certification
- Contribute to Kubernetes open source
- Join the Kubernetes community

**Keep learning and happy clustering!** 🚀
