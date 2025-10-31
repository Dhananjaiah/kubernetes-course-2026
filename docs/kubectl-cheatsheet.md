# kubectl Cheat Sheet

Quick reference for commonly used kubectl commands.

## Table of Contents
- [Basic Commands](#basic-commands)
- [Viewing Resources](#viewing-resources)
- [Creating Resources](#creating-resources)
- [Updating Resources](#updating-resources)
- [Deleting Resources](#deleting-resources)
- [Pods](#pods)
- [Deployments](#deployments)
- [Services](#services)
- [Namespaces](#namespaces)
- [ConfigMaps & Secrets](#configmaps--secrets)
- [Debugging](#debugging)
- [Cluster Information](#cluster-information)

---

## Basic Commands

```bash
# Get help
kubectl help
kubectl <command> --help

# View API versions
kubectl api-versions

# View API resources
kubectl api-resources

# Explain resource
kubectl explain pod
kubectl explain pod.spec.containers
```

---

## Viewing Resources

```bash
# Get resources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get all

# Get with more details
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json

# Get resources in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces

# Get with labels
kubectl get pods --show-labels
kubectl get pods -l app=nginx
kubectl get pods -l environment=production,tier=frontend

# Watch resources
kubectl get pods -w
kubectl get pods --watch

# Describe resource (detailed info)
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
```

---

## Creating Resources

```bash
# Create from file
kubectl create -f pod.yaml
kubectl create -f https://example.com/pod.yaml

# Create from multiple files
kubectl create -f pod.yaml -f service.yaml
kubectl create -f ./configs/

# Apply (declarative)
kubectl apply -f pod.yaml
kubectl apply -f ./configs/

# Create resources imperatively
kubectl create deployment nginx --image=nginx
kubectl create service clusterip my-svc --tcp=80:80
kubectl create configmap app-config --from-literal=key=value
kubectl create secret generic my-secret --from-literal=password=secret

# Run pod
kubectl run nginx --image=nginx
kubectl run busybox --image=busybox --command -- sleep 3600

# Dry run (don't create, just show)
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
```

---

## Updating Resources

```bash
# Edit resource
kubectl edit pod <pod-name>
kubectl edit deployment <deployment-name>

# Scale deployment
kubectl scale deployment <name> --replicas=5

# Update image
kubectl set image deployment/<name> container=image:tag

# Apply changes
kubectl apply -f updated-manifest.yaml

# Replace resource
kubectl replace -f pod.yaml

# Patch resource
kubectl patch deployment <name> -p '{"spec":{"replicas":3}}'
```

---

## Deleting Resources

```bash
# Delete specific resource
kubectl delete pod <pod-name>
kubectl delete deployment <deployment-name>

# Delete from file
kubectl delete -f pod.yaml

# Delete all pods in namespace
kubectl delete pods --all

# Delete by label
kubectl delete pods -l app=nginx

# Force delete (immediate)
kubectl delete pod <pod-name> --grace-period=0 --force

# Delete namespace (deletes all resources in it)
kubectl delete namespace <namespace-name>
```

---

## Pods

```bash
# List pods
kubectl get pods
kubectl get pods -n <namespace>
kubectl get pods --all-namespaces

# Create pod
kubectl run nginx --image=nginx
kubectl run nginx --image=nginx --port=80 --labels="app=nginx"

# Get pod details
kubectl describe pod <pod-name>
kubectl get pod <pod-name> -o yaml

# Pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs -f <pod-name>  # Follow
kubectl logs <pod-name> --previous  # Previous container
kubectl logs <pod-name> --tail=50  # Last 50 lines
kubectl logs <pod-name> --since=1h  # Last hour

# Execute command in pod
kubectl exec <pod-name> -- <command>
kubectl exec <pod-name> -- ls /app
kubectl exec <pod-name> -- env

# Interactive shell
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- /bin/sh

# Multi-container pods
kubectl logs <pod-name> -c <container-name>
kubectl exec -it <pod-name> -c <container-name> -- bash

# Port forwarding
kubectl port-forward pod/<pod-name> 8080:80
kubectl port-forward pod/<pod-name> :80  # Random local port

# Copy files
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file

# Delete pod
kubectl delete pod <pod-name>
```

---

## Deployments

```bash
# Create deployment
kubectl create deployment nginx --image=nginx
kubectl create deployment nginx --image=nginx --replicas=3

# List deployments
kubectl get deployments
kubectl get deploy

# Describe deployment
kubectl describe deployment <deployment-name>

# Scale deployment
kubectl scale deployment <deployment-name> --replicas=5

# Update deployment image
kubectl set image deployment/<name> <container>=<image>:<tag>
kubectl set image deployment/nginx nginx=nginx:1.21

# Rollout status
kubectl rollout status deployment/<deployment-name>

# Rollout history
kubectl rollout history deployment/<deployment-name>
kubectl rollout history deployment/<deployment-name> --revision=2

# Rollback
kubectl rollout undo deployment/<deployment-name>
kubectl rollout undo deployment/<deployment-name> --to-revision=2

# Pause/Resume rollout
kubectl rollout pause deployment/<deployment-name>
kubectl rollout resume deployment/<deployment-name>

# Delete deployment
kubectl delete deployment <deployment-name>
```

---

## Services

```bash
# List services
kubectl get services
kubectl get svc

# Create service (expose deployment)
kubectl expose deployment <name> --port=80 --target-port=8080
kubectl expose deployment <name> --type=NodePort --port=80
kubectl expose deployment <name> --type=LoadBalancer --port=80

# Create service from YAML
kubectl create -f service.yaml

# Describe service
kubectl describe service <service-name>

# Get service details
kubectl get service <service-name> -o yaml

# Get service endpoints
kubectl get endpoints <service-name>

# Delete service
kubectl delete service <service-name>
```

---

## Namespaces

```bash
# List namespaces
kubectl get namespaces
kubectl get ns

# Create namespace
kubectl create namespace <namespace-name>
kubectl create ns <namespace-name>

# Describe namespace
kubectl describe namespace <namespace-name>

# Set default namespace for context
kubectl config set-context --current --namespace=<namespace-name>

# View current namespace
kubectl config view --minify | grep namespace:

# Create resource in namespace
kubectl create -f pod.yaml -n <namespace-name>
kubectl run nginx --image=nginx -n <namespace-name>

# Get resources from namespace
kubectl get pods -n <namespace-name>
kubectl get all -n <namespace-name>

# Delete namespace
kubectl delete namespace <namespace-name>
```

---

## ConfigMaps & Secrets

### ConfigMaps

```bash
# Create from literal
kubectl create configmap app-config --from-literal=key1=value1 --from-literal=key2=value2

# Create from file
kubectl create configmap app-config --from-file=config.txt
kubectl create configmap app-config --from-file=./configs/

# Create from env file
kubectl create configmap app-config --from-env-file=.env

# List configmaps
kubectl get configmaps
kubectl get cm

# Describe configmap
kubectl describe configmap <configmap-name>

# Get configmap data
kubectl get configmap <configmap-name> -o yaml

# Delete configmap
kubectl delete configmap <configmap-name>
```

### Secrets

```bash
# Create from literal
kubectl create secret generic my-secret --from-literal=username=admin --from-literal=password=secret

# Create from file
kubectl create secret generic my-secret --from-file=username.txt --from-file=password.txt

# Create TLS secret
kubectl create secret tls tls-secret --cert=path/to/cert.crt --key=path/to/key.key

# Create docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=<server> \
  --docker-username=<username> \
  --docker-password=<password>

# List secrets
kubectl get secrets

# Describe secret (doesn't show values)
kubectl describe secret <secret-name>

# Get secret data (base64 encoded)
kubectl get secret <secret-name> -o yaml

# Decode secret
kubectl get secret <secret-name> -o jsonpath='{.data.password}' | base64 --decode

# Delete secret
kubectl delete secret <secret-name>
```

---

## Debugging

```bash
# Get pod status
kubectl get pod <pod-name>

# Describe pod (check events)
kubectl describe pod <pod-name>

# Get logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous
kubectl logs -f <pod-name>

# Execute commands
kubectl exec <pod-name> -- <command>
kubectl exec -it <pod-name> -- /bin/bash

# Debug with temporary pod
kubectl run debug --image=busybox --rm -it -- sh

# Check resource usage
kubectl top nodes
kubectl top pods
kubectl top pod <pod-name>

# Get events
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=<pod-name>

# Check component status
kubectl get componentstatuses
kubectl get cs

# Node details
kubectl describe node <node-name>

# Cluster info
kubectl cluster-info
kubectl cluster-info dump

# API server logs (on control plane)
kubectl logs -n kube-system kube-apiserver-<node-name>
```

---

## Cluster Information

```bash
# Cluster info
kubectl cluster-info

# Kubernetes version
kubectl version
kubectl version --short

# Get nodes
kubectl get nodes
kubectl get nodes -o wide

# Describe node
kubectl describe node <node-name>

# Node resource usage
kubectl top nodes

# Get component statuses
kubectl get componentstatuses

# View kubeconfig
kubectl config view
kubectl config view --minify

# Get contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>

# Get current context
kubectl config current-context
```

---

## Common Patterns

### Get resource in specific format
```bash
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o json
kubectl get pods -o name
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
```

### Filter and select
```bash
kubectl get pods --field-selector status.phase=Running
kubectl get pods --field-selector metadata.name=nginx
kubectl get pods -l app=nginx,environment=prod
```

### Sorting
```bash
kubectl get pods --sort-by=.metadata.name
kubectl get pods --sort-by=.status.startTime
```

### Custom columns
```bash
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```

---

## Useful Aliases

Add these to your `.bashrc` or `.zshrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kds='kubectl describe service'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kex='kubectl exec -it'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# Enable kubectl completion
source <(kubectl completion bash)
complete -F __start_kubectl k
```

---

## Quick Reference Card

| Command | Description |
|---------|-------------|
| `kubectl get` | List resources |
| `kubectl describe` | Show detailed resource info |
| `kubectl logs` | Print container logs |
| `kubectl exec` | Execute command in container |
| `kubectl apply` | Apply configuration |
| `kubectl delete` | Delete resources |
| `kubectl edit` | Edit resource |
| `kubectl scale` | Scale deployment |
| `kubectl rollout` | Manage rollouts |
| `kubectl port-forward` | Forward ports |
| `kubectl top` | Show resource usage |

---

For more details, see the official [kubectl documentation](https://kubernetes.io/docs/reference/kubectl/).
