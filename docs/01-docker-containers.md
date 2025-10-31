# Module 1: Docker & Containers

## Overview

This module introduces you to containerization technology and Docker. You'll learn why containers are essential for modern application deployment, understand Docker's architecture, and gain hands-on experience with Docker commands and workflows.

## Learning Objectives

By the end of this module, you will be able to:
- Explain the benefits of containers over traditional deployment methods
- Understand the difference between containers and virtual machines
- Work with Docker images and containers
- Build custom Docker images using Dockerfiles
- Push and pull images from container registries
- Use Docker CLI commands effectively

## Table of Contents

1. [Why Containers?](#why-containers)
2. [Containers vs Virtual Machines](#containers-vs-virtual-machines)
3. [Docker Components](#docker-components)
4. [Docker Images](#docker-images)
5. [Working with Containers](#working-with-containers)
6. [Dockerfiles](#dockerfiles)
7. [Container Registries](#container-registries)
8. [Docker CLI Reference](#docker-cli-reference)

---

## Why Containers?

### The Problem with Traditional Deployment

Before containers, deploying applications was challenging:

**The Old Way:**
- Every server needed the right runtime (Node.js, Java, Python, etc.)
- Library versions would drift: "works on my laptop, breaks in production"
- Developers write deploy scripts → Operations runs them → missing dependencies, different OS versions, patch levels... and repeat
- Running multiple applications on the same server caused dependency conflicts

**Example Problem Scenario:**
```
Developer's Laptop:
- Ubuntu 20.04
- Node.js 14.x
- npm packages version X

Production Server:
- CentOS 7
- Node.js 12.x
- npm packages version Y
- Different system libraries

Result: Application doesn't work!
```

### How Containers Solve These Problems

Containers encapsulate all the dependencies and configuration necessary to run an application. From the outside, they all look the same and are run the same way.

**Benefits of Containers:**

1. **Simplified Setup**
   - Package application with all dependencies
   - One command to run anywhere

2. **Portability**
   - Runs the same on development, testing, and production
   - "Build once, run anywhere"

3. **Consistent Environments**
   - Eliminates "works on my machine" problems
   - Same container image across all environments

4. **Isolation**
   - Applications don't interfere with each other
   - Each container has its own filesystem, networking, and processes

5. **Efficiency**
   - Lightweight compared to virtual machines
   - Fast startup times (seconds instead of minutes)
   - Better resource utilization

---

## Containers vs Virtual Machines

### Virtual Machines (VMs)

```
┌─────────────────────────────────────┐
│         Application + Deps          │
├─────────────────────────────────────┤
│         Guest Operating System       │
├─────────────────────────────────────┤
│            Hypervisor               │
├─────────────────────────────────────┤
│       Host Operating System         │
└─────────────────────────────────────┘
```

### Containers

```
┌─────────────────────────────────────┐
│         Application + Deps          │
├─────────────────────────────────────┤
│         Container Runtime           │
├─────────────────────────────────────┤
│       Host Operating System         │
└─────────────────────────────────────┘
```

### Comparison Table

| Aspect | Virtual Machines (VMs) | Containers |
|--------|------------------------|------------|
| **What's inside** | Your app + deps + full OS | Your app + deps (no OS) |
| **Starts in** | Minutes | Seconds |
| **Size** | GBs (includes OS) | MBs (just app + deps) |
| **Isolation** | Strong (full OS isolation) | Process-level isolation |
| **Resource usage** | Higher overhead | Lightweight |
| **Portability** | Good (with hypervisor) | Excellent (container runtime) |
| **Performance** | Slower (virtualization overhead) | Near-native performance |

### When to Use Each?

**Use Virtual Machines when:**
- You need complete isolation (security-critical workloads)
- Running different operating systems on the same hardware
- Legacy applications requiring full OS features
- Strong multi-tenancy requirements

**Use Containers when:**
- Deploying microservices
- CI/CD pipelines
- Development environments
- Cloud-native applications
- Need rapid scaling and deployment

**Best of Both Worlds:**
Many organizations run containers inside VMs for added security and isolation!

---

## Docker Components

Docker architecture consists of several components working together:

```
┌──────────────────┐         ┌────────────────────────────┐         ┌──────────────────┐
│  Docker Client   │         │      Docker Host           │         │ Image Registry   │
│                  │         │                            │         │                  │
│  - docker CLI    │────────▶│  - Docker Daemon           │────────▶│  - Docker Hub    │
│  - REST API      │  API    │  - Containers              │  Pull/  │  - Private       │
│    calls         │  calls  │  - Images                  │  Push   │    Registry      │
│                  │         │  - Volumes                 │         │                  │
└──────────────────┘         └────────────────────────────┘         └──────────────────┘
```

### 1. Docker Client

**What it is:** The tool you use to interact with Docker

**Components:**
- **Docker CLI**: Command-line interface (`docker run`, `docker ps`, etc.)
- **REST API**: Used by applications to interact with Docker programmatically

**Examples:**
```bash
docker run nginx           # Run a container
docker ps                  # List running containers
docker images              # List images
```

### 2. Docker Host

**What it is:** The machine that actually runs containers

**Components:**

- **Docker Daemon (`dockerd`)**
  - Background service that manages containers
  - Listens for Docker API requests
  - Manages images, containers, networks, and volumes

- **Containers**
  - Running instances of images
  - Isolated processes with their own filesystem

- **Images**
  - Read-only templates used to create containers
  - Built in layers for efficiency

- **Volumes**
  - Persistent storage for container data

### 3. Container Registry

**What it is:** A repository for storing and distributing Docker images

**Types:**
- **Public Registries**
  - Docker Hub (default)
  - GitHub Container Registry
  - Google Container Registry

- **Private Registries**
  - Self-hosted registries
  - AWS ECR, Azure ACR, Google GCR

**Example Workflow:**
```bash
# Pull an image from Docker Hub
docker pull nginx:latest

# Tag your image
docker tag myapp:latest username/myapp:v1

# Push to registry
docker push username/myapp:v1
```

---

## Docker Images

### What is a Docker Image?

A Docker image is a **read-only template** containing:
- Application code
- Runtime environment
- System tools and libraries
- Environment variables
- Configuration files

### Image Layers

Images are built in layers, which makes them efficient:

```
┌─────────────────────────┐
│  Application Code       │  ← Layer 4 (your app)
├─────────────────────────┤
│  App Dependencies       │  ← Layer 3 (npm packages)
├─────────────────────────┤
│  Node.js Runtime        │  ← Layer 2 (Node.js)
├─────────────────────────┤
│  Base OS (Ubuntu)       │  ← Layer 1 (base image)
└─────────────────────────┘
```

**Benefits of Layered Architecture:**
- Layers are cached and reused
- Only changed layers need to be rebuilt
- Efficient storage and transfer

### Working with Images

```bash
# List local images
docker images

# Pull an image from registry
docker pull ubuntu:20.04
docker pull nginx:latest

# Search for images
docker search nginx

# Remove an image
docker rmi nginx:latest

# Remove unused images
docker image prune
```

### Image Naming Convention

```
[registry-host]/[username]/[repository]:[tag]

Examples:
docker.io/library/nginx:latest        # Official nginx image
gcr.io/my-project/my-app:v1.0        # Google Container Registry
myregistry.com:5000/myapp:dev        # Private registry
```

---

## Working with Containers

### Container Lifecycle

```
┌─────────┐   start    ┌─────────┐   pause    ┌─────────┐
│ Created │──────────▶ │ Running │──────────▶ │ Paused  │
└─────────┘            └─────────┘            └─────────┘
     │                      │                      │
     │                      │ stop                 │ unpause
     │                      ▼                      │
     │                 ┌─────────┐                │
     └────────────────▶│ Stopped │◀───────────────┘
                       └─────────┘
                            │ rm
                            ▼
                       ┌─────────┐
                       │ Removed │
                       └─────────┘
```

### Basic Container Operations

#### Running Containers

```bash
# Run a container (creates and starts it)
docker run nginx

# Run in background (detached mode)
docker run -d nginx

# Run with a custom name
docker run --name my-nginx nginx

# Run and expose ports
docker run -d -p 8080:80 nginx

# Run with environment variables
docker run -e "ENV=production" myapp

# Run with volume mount
docker run -v /host/path:/container/path nginx

# Run interactively with terminal
docker run -it ubuntu bash
```

#### Managing Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop container_id

# Start a stopped container
docker start container_id

# Restart a container
docker restart container_id

# Pause a container
docker pause container_id

# Unpause a container
docker unpause container_id

# Remove a container
docker rm container_id

# Remove all stopped containers
docker container prune
```

#### Inspecting Containers

```bash
# View container logs
docker logs container_id
docker logs -f container_id  # Follow logs

# Inspect container details
docker inspect container_id

# View container processes
docker top container_id

# View resource usage stats
docker stats container_id

# Execute command in running container
docker exec -it container_id bash
```

---

## Dockerfiles

### What is a Dockerfile?

A Dockerfile is a text file containing instructions to build a Docker image automatically.

### Basic Dockerfile Structure

```dockerfile
# Base image
FROM ubuntu:20.04

# Metadata
LABEL maintainer="your-email@example.com"
LABEL description="My application"

# Set working directory
WORKDIR /app

# Copy files
COPY . /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y python3 && \
    apt-get clean

# Set environment variables
ENV APP_ENV=production

# Expose ports
EXPOSE 8080

# Define entrypoint
CMD ["python3", "app.py"]
```

### Common Dockerfile Instructions

| Instruction | Purpose | Example |
|------------|---------|---------|
| `FROM` | Base image | `FROM node:14` |
| `RUN` | Execute commands during build | `RUN npm install` |
| `COPY` | Copy files from host to image | `COPY . /app` |
| `ADD` | Copy files (can extract archives) | `ADD archive.tar /app` |
| `WORKDIR` | Set working directory | `WORKDIR /app` |
| `ENV` | Set environment variable | `ENV NODE_ENV=production` |
| `EXPOSE` | Document port | `EXPOSE 3000` |
| `CMD` | Default command to run | `CMD ["npm", "start"]` |
| `ENTRYPOINT` | Configurable entrypoint | `ENTRYPOINT ["node"]` |
| `USER` | Set user | `USER node` |
| `VOLUME` | Create mount point | `VOLUME /data` |

### Building Images

```bash
# Build image from Dockerfile
docker build -t myapp:v1 .

# Build with custom Dockerfile name
docker build -f Dockerfile.prod -t myapp:prod .

# Build with build arguments
docker build --build-arg VERSION=1.0 -t myapp:v1 .
```

### Best Practices

1. **Use specific base image tags**
   ```dockerfile
   # Good
   FROM node:14.17-alpine
   
   # Avoid
   FROM node:latest
   ```

2. **Minimize layers**
   ```dockerfile
   # Good - single RUN layer
   RUN apt-get update && \
       apt-get install -y package1 package2 && \
       apt-get clean
   
   # Avoid - multiple layers
   RUN apt-get update
   RUN apt-get install -y package1
   RUN apt-get install -y package2
   ```

3. **Use .dockerignore**
   ```
   node_modules
   npm-debug.log
   .git
   .env
   ```

4. **Order layers by change frequency**
   - Less frequently changed instructions first
   - Frequently changed instructions last

---

## Container Registries

### Docker Hub

Default public registry for Docker images.

```bash
# Login
docker login

# Tag image
docker tag myapp:v1 username/myapp:v1

# Push to Docker Hub
docker push username/myapp:v1

# Pull from Docker Hub
docker pull username/myapp:v1
```

### Private Registries

```bash
# Login to private registry
docker login myregistry.com:5000

# Tag for private registry
docker tag myapp:v1 myregistry.com:5000/myapp:v1

# Push to private registry
docker push myregistry.com:5000/myapp:v1
```

---

## Docker CLI Reference

### Essential Commands

```bash
# Images
docker images                    # List images
docker pull <image>             # Download image
docker rmi <image>              # Remove image
docker build -t <name> .        # Build image

# Containers
docker ps                       # List running containers
docker ps -a                    # List all containers
docker run <image>              # Create and start container
docker start <container>        # Start container
docker stop <container>         # Stop container
docker rm <container>           # Remove container
docker logs <container>         # View logs
docker exec -it <container> sh  # Execute command

# System
docker version                  # Show version
docker info                     # Show system info
docker system prune             # Clean up unused resources
```

### Useful Flags

```bash
-d              # Detached mode (background)
-it             # Interactive with TTY
-p 8080:80      # Port mapping (host:container)
-v /host:/cont  # Volume mount
--name myapp    # Container name
-e KEY=value    # Environment variable
--rm            # Remove container after exit
```

---

## Hands-On Lab

### Lab 1: Your First Container

```bash
# 1. Run hello-world container
docker run hello-world

# 2. Run nginx web server
docker run -d -p 8080:80 --name my-nginx nginx

# 3. Access nginx in browser
# Open http://localhost:8080

# 4. View container logs
docker logs my-nginx

# 5. Stop and remove container
docker stop my-nginx
docker rm my-nginx
```

### Lab 2: Build a Custom Image

```bash
# 1. Create a directory
mkdir my-app && cd my-app

# 2. Create index.html
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<body>
  <h1>Hello from Docker!</h1>
</body>
</html>
EOF

# 3. Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

# 4. Build image
docker build -t my-web-app:v1 .

# 5. Run container
docker run -d -p 8080:80 my-web-app:v1

# 6. Test
curl http://localhost:8080

# 7. Clean up
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

---

## Summary

In this module, you learned:
- ✅ Why containers are essential for modern development
- ✅ How containers differ from virtual machines
- ✅ Docker architecture and components
- ✅ Working with images and containers
- ✅ Building custom images with Dockerfiles
- ✅ Using container registries

## Next Steps

Now that you understand containers and Docker, you're ready to move on to [Module 2: Kubernetes Architecture](02-kubernetes-architecture.md) where you'll learn how Kubernetes orchestrates containers at scale!

## Additional Resources

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Compose](https://docs.docker.com/compose/)

---

[← Back to Setup](00-setup.md) | [Next: Kubernetes Architecture →](02-kubernetes-architecture.md)
