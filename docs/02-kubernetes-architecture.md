# Module 2: Kubernetes Architecture

## Overview

This module introduces Kubernetes architecture and its core components. You'll learn how Kubernetes orchestrates containers at scale, understand the roles of control plane and worker nodes, and get familiar with the Kubernetes API.

## Learning Objectives

By the end of this module, you will be able to:
- Explain what Kubernetes is and why it's needed
- Understand Kubernetes architecture (control plane and worker nodes)
- Identify the role of each Kubernetes component
- Work with kubectl to interact with a cluster
- Understand how Kubernetes manages containerized applications

## Table of Contents

1. [What is Kubernetes?](#what-is-kubernetes)
2. [Why Kubernetes?](#why-kubernetes)
3. [Kubernetes Architecture](#kubernetes-architecture)
4. [Control Plane Components](#control-plane-components)
5. [Worker Node Components](#worker-node-components)
6. [How Kubernetes Works](#how-kubernetes-works)
7. [Installing Kubernetes Tooling](#installing-kubernetes-tooling)
8. [Your First kubectl Commands](#your-first-kubectl-commands)

---

## What is Kubernetes?

**Kubernetes (K8s)** is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications.

### The Name

- **Kubernetes** is Greek for "helmsman" or "pilot" (the person steering a ship)
- Often abbreviated as **K8s** (K + 8 characters + s)
- Originally developed by Google, now maintained by the Cloud Native Computing Foundation (CNCF)

### Key Capabilities

Kubernetes provides:
- **Container Scheduling**: Decides where to run containers based on resource requirements
- **Self-Healing**: Automatically restarts failed containers and replaces nodes
- **Horizontal Scaling**: Scales applications up or down based on demand
- **Service Discovery**: Applications can find and communicate with each other
- **Load Balancing**: Distributes traffic across multiple container instances
- **Rolling Updates**: Deploys updates without downtime
- **Configuration Management**: Manages secrets and configurations separately from code
- **Storage Orchestration**: Automatically mounts storage systems

---

## Why Kubernetes?

### Managing Containers at Scale

When you have just a few containers, Docker alone is sufficient. But as your application grows, you face challenges:

**Problems Without Orchestration:**

```
❌ Manually starting containers on servers
❌ No automatic recovery when containers crash
❌ Difficult to scale during traffic spikes
❌ Complex networking between containers
❌ Manual load balancing
❌ Downtime during updates
❌ No consistent deployment process
```

**Solutions with Kubernetes:**

```
✅ Automatically schedules containers across servers
✅ Restarts failed containers automatically
✅ Scales applications with a single command
✅ Built-in service discovery and DNS
✅ Automatic load balancing
✅ Zero-downtime rolling updates
✅ Declarative configuration (Infrastructure as Code)
```

### Real-World Use Cases

1. **Microservices Architecture**
   - Deploy and manage hundreds of microservices
   - Handle complex service-to-service communication

2. **CI/CD Pipelines**
   - Automate testing and deployment
   - Manage multiple environments (dev, staging, prod)

3. **Batch Processing**
   - Run scheduled jobs and batch workloads
   - Process data pipelines

4. **Machine Learning**
   - Deploy and scale ML models
   - Manage training workloads

---

## Kubernetes Architecture

Kubernetes follows a **master-worker architecture** (also called control plane and data plane).

### High-Level Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                        CONTROL PLANE                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  API Server  │  │  Scheduler   │  │  Controller  │  ┌────┐ │
│  │              │  │              │  │   Manager    │  │etcd│ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └────┘ │
└────────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
    ┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐
    │   Worker    │    │   Worker    │    │   Worker    │
    │   Node 1    │    │   Node 2    │    │   Node 3    │
    │             │    │             │    │             │
    │  ┌────────┐ │    │  ┌────────┐ │    │  ┌────────┐ │
    │  │Kubelet │ │    │  │Kubelet │ │    │  │Kubelet │ │
    │  │        │ │    │  │        │ │    │  │        │ │
    │  │  Pod   │ │    │  │  Pod   │ │    │  │  Pod   │ │
    │  │  Pod   │ │    │  │  Pod   │ │    │  │  Pod   │ │
    │  └────────┘ │    │  └────────┘ │    │  └────────┘ │
    └─────────────┘    └─────────────┘    └─────────────┘
```

### Components Overview

**Control Plane (Master Node):**
- API Server: Front-end for the Kubernetes control plane
- Scheduler: Assigns pods to nodes
- Controller Manager: Runs controller processes
- etcd: Key-value store for cluster data

**Worker Nodes:**
- Kubelet: Agent that runs on each node
- Kube-proxy: Network proxy
- Container Runtime: Docker, containerd, or CRI-O
- Pods: Running containers

---

## Control Plane Components

The control plane manages the Kubernetes cluster and makes global decisions about the cluster.

### 1. API Server (kube-apiserver)

**Role:** Front-end for the Kubernetes control plane

**What it does:**
- Exposes the Kubernetes API (RESTful)
- Authenticates and authorizes requests
- Validates and processes API requests
- Updates etcd with cluster state
- Only component that talks directly to etcd

**How you interact with it:**
```bash
kubectl get pods          # kubectl talks to API server
kubectl create -f pod.yaml  # API server processes request
```

**Key Points:**
- All cluster communication goes through the API server
- Stateless (state is stored in etcd)
- Can run multiple instances for high availability
- Listens on port 6443 (HTTPS)

### 2. Scheduler (kube-scheduler)

**Role:** Assigns pods to nodes

**What it does:**
- Watches for newly created pods with no assigned node
- Selects the best node for each pod based on:
  - Resource requirements (CPU, memory)
  - Hardware/software constraints
  - Affinity and anti-affinity rules
  - Data locality
  - Deadlines and priorities

**Example Decision Process:**
```
New Pod created → Scheduler watches → Evaluates nodes
                                     ↓
                    Node 1: 80% CPU (skip)
                    Node 2: 40% CPU, has SSD ✓
                    Node 3: 45% CPU (good)
                                     ↓
                    Assigns Pod to Node 2
```

**Key Points:**
- Makes placement decisions but doesn't run pods
- Kubelet on the node actually starts the pod
- Pluggable (can write custom schedulers)

### 3. Controller Manager (kube-controller-manager)

**Role:** Runs controller processes that regulate cluster state

**What it does:**
- Watches cluster state through API server
- Makes changes to move current state toward desired state
- Runs multiple controllers in a single process

**Common Controllers:**

| Controller | Purpose |
|-----------|---------|
| **Node Controller** | Monitors node health, takes action when nodes fail |
| **Replication Controller** | Maintains correct number of pods |
| **Endpoints Controller** | Populates Endpoints object (joins Services & Pods) |
| **Service Account Controller** | Creates default accounts for new namespaces |
| **Namespace Controller** | Manages namespace lifecycle |

**Example - Replication Controller:**
```
Desired State: 3 replicas of nginx
Current State: 2 replicas running (1 crashed)

Replication Controller detects discrepancy
    ↓
Creates new pod to match desired state
    ↓
Current State: 3 replicas (matches desired state) ✓
```

### 4. etcd

**Role:** Consistent and highly available key-value store for all cluster data

**What it stores:**
- Cluster configuration
- Current state of all resources
- Secrets and ConfigMaps
- Service discovery information

**Example Data:**
```
/registry/pods/default/nginx-pod
/registry/services/default/web-service
/registry/deployments/production/api
```

**Key Points:**
- Single source of truth for cluster state
- Only API server reads/writes to etcd
- Should be backed up regularly
- Typically runs on control plane nodes
- Uses Raft consensus algorithm for consistency

**High Availability:**
- Run 3 or 5 etcd instances (odd numbers)
- Distributed across availability zones
- Can survive loss of (n-1)/2 instances

---

## Worker Node Components

Worker nodes run containerized applications. Each node has components that maintain running pods.

### 1. Kubelet

**Role:** Agent that runs on each worker node

**What it does:**
- Registers node with API server
- Watches API server for pod assignments
- Ensures containers in pods are running and healthy
- Reports node and pod status back to API server
- Executes container lifecycle hooks

**Responsibilities:**
```
API Server assigns Pod to Node
        ↓
Kubelet receives assignment
        ↓
Pulls container images
        ↓
Starts containers via container runtime
        ↓
Monitors container health
        ↓
Reports status to API server
```

**Key Points:**
- Only component that runs containers
- Works with container runtime via CRI (Container Runtime Interface)
- Performs health checks (liveness, readiness probes)
- Mounts volumes
- Runs on every node (including control plane in some setups)

### 2. Kube-proxy

**Role:** Network proxy running on each node

**What it does:**
- Maintains network rules on nodes
- Implements Kubernetes Service concept
- Handles load balancing for Services
- Manages iptables or IPVS rules

**How it works:**
```
Client makes request to Service (ClusterIP)
        ↓
Kube-proxy intercepts traffic
        ↓
Forwards to one of the backend Pods
        ↓
Pod processes request and responds
```

**Key Points:**
- Enables Service abstraction
- Can use different modes: iptables, IPVS, or userspace
- Watches API server for Service/Endpoint changes
- Updates routing rules dynamically

### 3. Container Runtime

**Role:** Software responsible for running containers

**Supported Runtimes:**
- **containerd** (most common, Docker's core)
- **CRI-O** (lightweight, built for Kubernetes)
- **Docker** (via dockershim, deprecated in K8s 1.24+)

**What it does:**
- Pulls container images from registries
- Runs containers
- Manages container lifecycle
- Provides container isolation

**Key Points:**
- Must implement CRI (Container Runtime Interface)
- Handles low-level container operations
- Works with Kubelet to manage containers

---

## How Kubernetes Works

### Pod Creation Flow

Let's follow what happens when you create a pod:

```
1. User runs: kubectl create -f pod.yaml
              ↓
2. kubectl sends request to API Server
              ↓
3. API Server validates and stores in etcd
              ↓
4. Scheduler watches API Server, sees unscheduled pod
              ↓
5. Scheduler selects best node, updates API Server
              ↓
6. Kubelet on selected node watches API Server
              ↓
7. Kubelet sees pod assignment, pulls image
              ↓
8. Kubelet tells Container Runtime to start container
              ↓
9. Kubelet reports pod status to API Server
              ↓
10. API Server updates etcd with pod status
```

### Self-Healing Example

```
Pod crashes on Node 2
        ↓
Kubelet detects failure, reports to API Server
        ↓
Controller Manager watches API Server
        ↓
Replication Controller sees pod count < desired
        ↓
Creates new pod specification
        ↓
Scheduler assigns to available node
        ↓
Kubelet on new node starts pod
        ↓
System returns to desired state ✓
```

---

## Installing Kubernetes Tooling

### kubectl Setup

You should have installed kubectl in Module 0. Verify installation:

```bash
# Check version
kubectl version --client

# Set up autocompletion (bash)
source <(kubectl completion bash)
echo 'source <(kubectl completion bash)' >> ~/.bashrc

# Create alias
alias k=kubectl
echo 'alias k=kubectl' >> ~/.bashrc
complete -F __start_kubectl k
```

### Verify Cluster Access

```bash
# Check cluster info
kubectl cluster-info

# View cluster nodes
kubectl get nodes

# View all cluster resources
kubectl get all --all-namespaces
```

---

## Your First kubectl Commands

### Basic Commands

```bash
# Get cluster information
kubectl cluster-info
kubectl version

# View nodes
kubectl get nodes
kubectl describe node <node-name>

# View namespaces
kubectl get namespaces

# View all resources in all namespaces
kubectl get all -A

# View component status
kubectl get componentstatuses
```

### Understanding Output

```bash
$ kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   5d    v1.28.3

# STATUS: Node health (Ready, NotReady, Unknown)
# ROLES: control-plane or <none> for workers
# AGE: Time since node joined cluster
# VERSION: Kubernetes version running on node
```

### Getting Help

```bash
# General help
kubectl help

# Help for specific command
kubectl create --help
kubectl get --help

# Explain resource types
kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers
```

---

## Hands-On Lab

### Lab 1: Explore Your Cluster

```bash
# 1. Check cluster info
kubectl cluster-info

# 2. List all nodes
kubectl get nodes -o wide

# 3. Describe a node to see details
kubectl describe node $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')

# 4. View system pods
kubectl get pods -n kube-system

# 5. Check API versions
kubectl api-versions

# 6. List all API resources
kubectl api-resources
```

### Lab 2: Understand API Resources

```bash
# 1. List all resource types
kubectl api-resources

# 2. Get detailed info about pods
kubectl explain pods

# 3. Get info about pod spec
kubectl explain pod.spec

# 4. Get info about containers
kubectl explain pod.spec.containers

# 5. View in different formats
kubectl get nodes -o json
kubectl get nodes -o yaml
```

---

## Summary

In this module, you learned:
- ✅ What Kubernetes is and why it's essential for container orchestration
- ✅ Kubernetes architecture (control plane and worker nodes)
- ✅ Role of each Kubernetes component
- ✅ How Kubernetes makes decisions and maintains desired state
- ✅ Basic kubectl commands to interact with your cluster

### Key Takeaways

1. **Kubernetes is declarative**: You define desired state, Kubernetes maintains it
2. **API Server is central**: All components communicate through it
3. **Controllers watch and react**: They move current state toward desired state
4. **Kubelet runs containers**: It's the only component that actually starts containers
5. **etcd is the source of truth**: All cluster state is stored here

## Next Steps

Now that you understand Kubernetes architecture, you're ready to learn about [Module 3: Pods](03-pods.md) - the smallest deployable units in Kubernetes!

## Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CNCF Kubernetes Landscape](https://landscape.cncf.io/)

---

[← Previous: Docker & Containers](01-docker-containers.md) | [Next: Pods →](03-pods.md)
