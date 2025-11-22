# Kubernetes Course 2026

A comprehensive, hands-on Kubernetes course from containers to production-ready deployments. This course takes you from Docker basics through advanced Kubernetes concepts with practical examples and exercises.

## 🚀 NEW: Real-World Microservices Project

**Now includes a production-ready e-commerce microservices application!**

The `microservices/` directory contains a complete microservices architecture with:
- 5 microservices (Frontend, Product, User, Order, Cart)
- 3 databases (MongoDB, PostgreSQL, Redis)
- Full Kubernetes manifests
- Docker Compose for local development
- Comprehensive documentation

👉 **[Get Started with Microservices →](microservices/README.md)**

## 📚 Course Overview

This course covers everything you need to master Kubernetes, starting with container fundamentals and progressing through production-grade cluster management. Each module includes theory, practical examples, hands-on labs, and a **real-world microservices project** to apply your knowledge.

## 🎯 Prerequisites

- Basic understanding of Linux command line
- Familiarity with basic networking concepts
- A computer with at least 8GB RAM for running Kubernetes locally
- Willingness to learn and experiment!

## 🛠️ Setup Requirements

Before starting this course, you'll need to install:

1. **Docker** - Container runtime
2. **kubectl** - Kubernetes command-line tool
3. **Minikube** or **kind** - Local Kubernetes cluster
4. **Git** - For cloning this repository

### Installation Options

Choose the Kubernetes installation method that best fits your needs:

- **For Learning & Local Development**: [Minikube](installations/local/minikube.md), [kind](installations/local/kind.md), [k3d](installations/local/k3d.md)
- **For Mac/Windows Users**: [Docker Desktop](installations/local/docker-desktop.md), [Rancher Desktop](installations/local/rancher-desktop.md), [Colima](installations/local/colima.md)
- **For Edge/IoT**: [K3s](installations/local/k3s.md), [MicroK8s](installations/local/microk8s.md)
- **For Production**: [kubeadm](installations/bare-metal/kubeadm.md), [Kubespray](installations/bare-metal/kubespray.md), [RKE2](installations/bare-metal/rancher-rke2.md)

👉 **[View All Installation Options →](installations/README.md)**

Detailed setup instructions for Minikube are available in [docs/00-setup.md](docs/00-setup.md)

## 📖 Course Modules

### Module 1: Docker & Containers (Foundation)
- Understanding containers vs virtual machines
- Docker architecture and components
- Working with Docker images and containers
- Dockerfile best practices
- Container registries
- **Labs**: Building and running containerized applications

### Module 2: Kubernetes Architecture
- Kubernetes components overview
- Control plane components (API Server, Scheduler, Controller Manager, etcd)
- Worker node components (Kubelet, Kube-proxy, Container Runtime)
- Understanding the Kubernetes API
- **Labs**: Setting up your first Kubernetes cluster

### Module 3: Pods & Pod Lifecycle
- Understanding Pods as the smallest deployable unit
- Pod lifecycle phases (Pending, Running, Succeeded, Failed, Unknown)
- Container restart policies
- CrashLoopBackOff and troubleshooting
- Multi-container pods
- **Labs**: Creating and managing Pods

### Module 4: Namespaces
- What are namespaces and why they matter
- Default namespaces in Kubernetes
- Resource isolation and organization
- Resource quotas and limits
- **Labs**: Creating and managing namespaces

### Module 5: ReplicaSets
- Understanding ReplicaSets
- How ReplicaSets maintain desired state
- Labels and selectors
- Scaling applications
- **Labs**: Working with ReplicaSets

### Module 6: Deployments
- Deployments as the preferred way to manage applications
- Deployment strategies
- Updating and rolling back deployments
- Scaling deployments
- **Labs**: Managing application lifecycle with Deployments

### Module 7: Labels & Selectors
- Understanding labels and annotations
- Label selectors (equality-based and set-based)
- Using labels for organization and selection
- Best practices for labeling
- **Labs**: Organizing resources with labels

### Module 8: Services
- Why Services are needed
- Service types: ClusterIP, NodePort, LoadBalancer
- Service discovery and DNS
- Endpoints and EndpointSlices
- **Labs**: Exposing applications with Services

### Module 9: Update Strategies & Rollback
- Recreate vs Rolling Update strategies
- Configuring update strategies
- Health checks during updates
- Rolling back failed deployments
- **Labs**: Safe application updates and rollbacks

### Module 10: Cluster Maintenance
- Scaling clusters (adding/removing nodes)
- Cordon and Uncordon nodes
- Draining nodes safely
- Cluster upgrades
- **Labs**: Maintaining a Kubernetes cluster

### Module 11: DaemonSets, Jobs & CronJobs
- DaemonSets for node-level services
- Jobs for batch processing
- CronJobs for scheduled tasks
- Use cases and best practices
- **Labs**: Running background tasks and scheduled jobs

### Module 12: ConfigMaps & Secrets
- Externalizing configuration with ConfigMaps
- Managing sensitive data with Secrets
- Mounting configs as files or environment variables
- Best practices for configuration management
- **Labs**: Configuration management patterns

### Module 13: Health Probes
- Liveness, Readiness, and Startup probes
- Probe types: HTTP, TCP, Exec
- Configuring probe parameters
- Probe best practices
- **Labs**: Implementing health checks

### Module 14: Node Scheduling
- How the Kubernetes scheduler works
- Node selection with nodeName
- Node selectors for label-based scheduling
- Node affinity and anti-affinity rules
- **Labs**: Controlling Pod placement

### Module 15: Taints & Tolerations
- Understanding taints and tolerations
- Taint effects: NoSchedule, PreferNoSchedule, NoExecute
- Using taints for dedicated nodes
- Eviction and pod lifecycle
- **Labs**: Advanced scheduling with taints

### Module 16: Storage & Persistence
- Volumes overview (emptyDir, hostPath, etc.)
- Persistent Volumes (PV) and Persistent Volume Claims (PVC)
- Storage classes and dynamic provisioning
- Reclaim policies
- **Labs**: Persistent storage for applications

### Module 17: StatefulSets
- StatefulSets for stateful applications
- Stable network identities
- Ordered deployment and scaling
- Persistent storage with StatefulSets
- **Labs**: Deploying databases with StatefulSets

### Module 18: RBAC (Role-Based Access Control)
- Understanding RBAC in Kubernetes
- Roles and ClusterRoles
- RoleBindings and ClusterRoleBindings
- Creating and managing users
- **Labs**: Implementing access control

### Module 19: Ingress
- Understanding Ingress and Ingress Controllers
- Path-based and host-based routing
- TLS/SSL termination
- Ingress annotations
- **Labs**: Exposing applications with Ingress

### Module 20: Network Policies
- Understanding Kubernetes networking
- Default allow vs default deny
- Ingress and egress rules
- Pod-to-pod network policies
- **Labs**: Securing pod communication

### Module 21: Helm - Package Manager
- Introduction to Helm
- Helm charts structure
- Installing and managing releases
- Creating custom charts
- Helm best practices
- **Labs**: Packaging and deploying with Helm

## 🚀 Getting Started

**New to this course?** Start here: **[GETTING-STARTED.md](GETTING-STARTED.md)** - Complete beginner's guide

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/Dhananjaiah/kubernetes-course-2026.git
   cd kubernetes-course-2026
   ```

2. Set up your environment following [docs/00-setup.md](docs/00-setup.md)

3. Start with Module 1 in [docs/01-docker-containers.md](docs/01-docker-containers.md)

4. Work through each module sequentially, completing the labs

### 📚 Essential Resources

- 🚀 **[Microservices Project](microservices/README.md)** - Real-world e-commerce application
- 📖 **[Getting Started Guide](GETTING-STARTED.md)** - Your roadmap to success
- 🛠️ **[Kubernetes Installations](installations/README.md)** - Complete installation guides
- 📋 **[Setup Instructions](docs/00-setup.md)** - Install Docker, kubectl, Minikube
- 📝 **[kubectl Cheat Sheet](docs/kubectl-cheatsheet.md)** - Quick command reference
- ❓ **[FAQ](docs/FAQ.md)** - Common questions and troubleshooting
- 🤝 **[Contributing Guide](CONTRIBUTING.md)** - Help improve this course

## 📁 Repository Structure

```
kubernetes-course-2026/
├── README.md                          # This file
├── K8s-Runbook.pptx                  # Original presentation
├── microservices/                    # 🆕 Real-world microservices project
│   ├── frontend/                     # API Gateway service
│   ├── product-service/              # Product catalog service
│   ├── user-service/                 # User authentication service
│   ├── order-service/                # Order management service
│   ├── cart-service/                 # Shopping cart service
│   ├── k8s/                          # Kubernetes manifests
│   ├── docker-compose.yml            # Local development setup
│   ├── README.md                     # Microservices documentation
│   └── ARCHITECTURE.md               # Architecture details
├── installations/                    # 🆕 Kubernetes installation guides
│   ├── README.md                     # Installation overview
│   ├── local/                        # Local/laptop installations
│   │   ├── minikube.md               # Minikube setup
│   │   ├── kind.md                   # kind (Kubernetes in Docker)
│   │   ├── k3d.md                    # k3d (K3s in Docker)
│   │   ├── k3s.md                    # K3s (lightweight Kubernetes)
│   │   ├── microk8s.md               # MicroK8s
│   │   ├── docker-desktop.md         # Docker Desktop Kubernetes
│   │   ├── rancher-desktop.md        # Rancher Desktop
│   │   └── colima.md                 # Colima + Kubernetes
│   └── bare-metal/                   # Production/bare-metal installations
│       ├── kubeadm.md                # kubeadm
│       ├── kubespray.md              # Kubespray (Ansible)
│       ├── kops.md                   # kOps (AWS)
│       ├── rancher-rke.md            # Rancher RKE
│       ├── rancher-rke2.md           # Rancher RKE2
│       ├── talos-linux.md            # Talos Linux
│       └── coreos-flatcar.md         # CoreOS/Flatcar + kubeadm
├── docs/                             # Course documentation
│   ├── 00-setup.md                   # Setup instructions
│   ├── 01-docker-containers.md       # Module 1
│   ├── 02-kubernetes-architecture.md # Module 2
│   ├── 03-pods.md                    # Module 3
│   ├── ...                           # Additional modules
│   └── 21-helm.md                    # Module 21
├── labs/                             # Hands-on lab exercises
│   ├── 01-docker/                    # Docker labs
│   ├── 02-kubernetes/                # Kubernetes labs
│   └── ...                           # Additional labs
└── examples/                         # Example manifests and configurations
    ├── pods/
    ├── deployments/
    ├── services/
    └── ...
```

## 🎓 Learning Path

**Beginner** (Weeks 1-4)
- Modules 1-8: Docker basics through Services
- Focus on understanding core concepts
- Complete basic labs

**Intermediate** (Weeks 5-8)
- Modules 9-15: Updates, maintenance, and advanced scheduling
- Learn production best practices
- Work on more complex labs

**Advanced** (Weeks 9-12)
- Modules 16-21: Storage, security, and tooling
- Explore advanced patterns
- Build real-world projects

## 🤝 Contributing

Contributions are welcome! We need help completing modules 5-21.

**How to contribute:**

1. Read the [Contributing Guide](CONTRIBUTING.md)
2. Fork the repository
3. Create a feature branch
4. Make your changes (add modules, examples, fix bugs)
5. Submit a pull request

**Contribution opportunities:**
- Complete remaining modules (5-21)
- Add more example YAML manifests
- Create additional labs and exercises
- Improve documentation
- Fix typos and broken links
- Translate content

## 📝 License

This course material is provided for educational purposes.

## 🙏 Acknowledgments

This course is based on practical, real-world Kubernetes experience and industry best practices. The content is designed to prepare you for production Kubernetes deployments.

## 📞 Support

If you have questions or need help:
- Open an issue in this repository
- Check the [FAQ](docs/FAQ.md)
- Review the troubleshooting guides in each module

---

**Happy Learning! 🚀**

Start your Kubernetes journey today and become a Kubernetes expert!
