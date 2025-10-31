# Getting Started with Kubernetes Course 2026

Welcome! This guide will help you get started with the Kubernetes Course 2026. Follow these steps to set up your environment and begin learning.

## 📋 Quick Start Checklist

- [ ] Review prerequisites
- [ ] Install required tools (Docker, kubectl, Minikube)
- [ ] Start your first Kubernetes cluster
- [ ] Run your first container in Kubernetes
- [ ] Complete Module 1 (Docker & Containers)
- [ ] Begin Module 2 (Kubernetes Architecture)

## 🎯 Before You Begin

### Who Is This Course For?

This course is designed for:
- **Developers** who want to deploy applications on Kubernetes
- **DevOps Engineers** transitioning to container orchestration
- **System Administrators** managing containerized infrastructure
- **Students** learning cloud-native technologies
- **Anyone** interested in Kubernetes!

### What You'll Learn

By the end of this course, you will be able to:
- Deploy and manage containerized applications
- Understand Kubernetes architecture and components
- Configure services, networking, and storage
- Implement security and access controls
- Use advanced features like Helm and Ingress
- Troubleshoot common Kubernetes issues
- Follow Kubernetes best practices

### Time Commitment

- **Total course time**: 8-12 weeks
- **Weekly time**: 3-5 hours
- **Each module**: 1-2 hours
- **Labs**: 30-60 minutes each

You can work at your own pace!

## 📚 Course Structure

The course is organized into 21 modules:

### Beginner Track (Weeks 1-4)
Focus on fundamentals and core concepts:
- Module 1: Docker & Containers
- Module 2: Kubernetes Architecture
- Module 3: Pods & Pod Lifecycle
- Module 4: Namespaces
- Module 5: ReplicaSets
- Module 6: Deployments
- Module 7: Labels & Selectors
- Module 8: Services

### Intermediate Track (Weeks 5-8)
Learn deployment strategies and cluster management:
- Module 9: Update Strategies & Rollback
- Module 10: Cluster Maintenance
- Module 11: DaemonSets, Jobs & CronJobs
- Module 12: ConfigMaps & Secrets
- Module 13: Health Probes
- Module 14: Node Scheduling
- Module 15: Taints & Tolerations

### Advanced Track (Weeks 9-12)
Master storage, security, and production concepts:
- Module 16: Storage & Persistence
- Module 17: StatefulSets
- Module 18: RBAC
- Module 19: Ingress
- Module 20: Network Policies
- Module 21: Helm

## 🛠️ Setup Your Environment

### Step 1: Check System Requirements

**Minimum:**
- CPU: 2 cores
- RAM: 8 GB
- Disk: 20 GB free
- OS: Linux, macOS, or Windows 10+

**Recommended:**
- CPU: 4 cores or more
- RAM: 16 GB or more
- Disk: 50 GB free

### Step 2: Install Docker

Docker is required for running containers.

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Log out and back in
docker --version
```

**macOS:**
```bash
brew install --cask docker
# Or download from https://www.docker.com/products/docker-desktop
```

**Windows:**
Download Docker Desktop from https://www.docker.com/products/docker-desktop

### Step 3: Install kubectl

kubectl is the Kubernetes command-line tool.

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

**macOS:**
```bash
brew install kubectl
kubectl version --client
```

**Windows:**
```powershell
choco install kubernetes-cli
kubectl version --client
```

### Step 4: Install Minikube

Minikube runs a local Kubernetes cluster.

**Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

**macOS:**
```bash
brew install minikube
minikube version
```

**Windows:**
```powershell
choco install minikube
minikube version
```

### Step 5: Start Your Cluster

```bash
# Start Minikube
minikube start --cpus=2 --memory=4096 --driver=docker

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

You should see output like:
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.28.3
```

### Step 6: Run Your First Pod

```bash
# Create a simple nginx pod
kubectl run nginx --image=nginx

# Check pod status
kubectl get pods

# Test the pod
kubectl port-forward pod/nginx 8080:80
# Visit http://localhost:8080 in your browser

# Clean up
kubectl delete pod nginx
```

Congratulations! You've successfully run your first container in Kubernetes! 🎉

## 📖 How to Use This Course

### 1. Start with Module 0

Read the [Setup Guide](docs/00-setup.md) for detailed installation instructions and troubleshooting.

### 2. Follow Modules Sequentially

Each module builds on previous concepts:

```
Module 1 → Module 2 → Module 3 → ... → Module 21
```

### 3. Complete Hands-On Labs

Every module includes practical labs. **Actually do them!** Hands-on practice is essential for learning Kubernetes.

### 4. Use Example Files

The `examples/` directory contains YAML manifests you can use:

```bash
# Apply an example
kubectl apply -f examples/pods/simple-pod.yaml

# Verify it's running
kubectl get pods

# Clean up
kubectl delete -f examples/pods/simple-pod.yaml
```

### 5. Refer to Cheat Sheets

- [kubectl Cheat Sheet](docs/kubectl-cheatsheet.md) - Quick command reference
- [FAQ](docs/FAQ.md) - Common questions and troubleshooting

### 6. Practice, Practice, Practice

- Re-do labs with variations
- Break things on purpose and fix them
- Build small projects
- Document what you learn

## 🚀 Your First Learning Session

Here's a suggested plan for your first 2 hours:

**Session 1: Environment Setup (30 minutes)**
1. Install Docker, kubectl, and Minikube
2. Start your cluster
3. Run your first pod
4. Explore basic kubectl commands

**Session 2: Docker Fundamentals (60 minutes)**
1. Read [Module 1: Docker & Containers](docs/01-docker-containers.md)
2. Complete Lab 1: Your First Container
3. Complete Lab 2: Build a Custom Image
4. Try the example Dockerfiles

**Session 3: Kubernetes Overview (30 minutes)**
1. Start [Module 2: Kubernetes Architecture](docs/02-kubernetes-architecture.md)
2. Understand control plane components
3. Complete Lab 1: Explore Your Cluster

## 📝 Study Tips

### Best Practices for Learning

1. **Take Notes**: Write down key concepts in your own words
2. **Practice Daily**: Even 15 minutes a day helps
3. **Break Things**: Learn by fixing mistakes
4. **Ask Questions**: Use the FAQ or open issues
5. **Build Projects**: Apply what you learn to real scenarios

### Common Pitfalls to Avoid

❌ **Skipping labs** - Hands-on practice is essential
❌ **Rushing through modules** - Take time to understand concepts
❌ **Not reading error messages** - They contain valuable information
❌ **Memorizing commands** - Focus on understanding concepts
❌ **Working in isolation** - Join communities, ask questions

### Debugging Tips

When something doesn't work:

```bash
# 1. Check pod status
kubectl get pods

# 2. Describe the pod (shows events)
kubectl describe pod <pod-name>

# 3. Check logs
kubectl logs <pod-name>

# 4. Check cluster status
kubectl get nodes
kubectl get all -A
```

Also check the [FAQ](docs/FAQ.md) for solutions to common problems.

## 🎓 Learning Resources

### Within This Course

- 📚 [Course Modules](docs/) - All course content
- 💻 [Example Manifests](examples/) - YAML files to practice with
- 📋 [kubectl Cheat Sheet](docs/kubectl-cheatsheet.md) - Quick reference
- ❓ [FAQ](docs/FAQ.md) - Common questions

### External Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/) - Comprehensive documentation
- [Kubernetes Slack](https://kubernetes.slack.com/) - Community support
- [CNCF YouTube](https://www.youtube.com/c/cloudnativefdn) - Videos and talks
- [Kubernetes Podcast](https://kubernetespodcast.com/) - Weekly news

## 🎯 Setting Goals

Define your learning goals. Examples:

**Short-term (1-2 weeks):**
- [ ] Complete beginner modules (1-8)
- [ ] Deploy a multi-tier application
- [ ] Understand services and networking

**Medium-term (1-2 months):**
- [ ] Complete all 21 modules
- [ ] Build a real project
- [ ] Learn CI/CD with Kubernetes

**Long-term (3-6 months):**
- [ ] Pass CKA or CKAD certification
- [ ] Deploy production applications
- [ ] Contribute to open source

## 🤝 Getting Help

### If You're Stuck

1. **Check the FAQ**: [docs/FAQ.md](docs/FAQ.md)
2. **Review the module**: Re-read relevant sections
3. **Check logs and events**: Use kubectl describe and logs
4. **Search online**: Kubernetes docs, Stack Overflow
5. **Open an issue**: Describe your problem in detail

### Community Support

- **GitHub Issues**: For course-specific questions
- **Kubernetes Slack**: For general Kubernetes questions
- **Stack Overflow**: Tag questions with `kubernetes`
- **Reddit**: r/kubernetes community

## ✅ Ready to Start?

You're all set! Here's your next steps:

1. ✅ Environment is set up
2. ➡️ Start with [Module 1: Docker & Containers](docs/01-docker-containers.md)
3. 📝 Complete the hands-on labs
4. 🚀 Move to Module 2 when ready

## 📞 Contact & Feedback

Have feedback or suggestions?
- Open an issue on GitHub
- Contribute improvements (see [CONTRIBUTING.md](CONTRIBUTING.md))
- Share your success stories!

---

**Remember**: Everyone learns at their own pace. Don't rush, practice consistently, and most importantly - have fun learning Kubernetes! 🚀

**Ready?** Let's begin with [Module 1: Docker & Containers](docs/01-docker-containers.md)!
