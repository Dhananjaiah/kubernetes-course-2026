# Quick Start Guide

Get the e-commerce microservices application running in minutes!

## Prerequisites

- Docker and Docker Compose installed
- OR Kubernetes cluster (Minikube, kind, or cloud provider) with kubectl

## Option 1: Docker Compose (Fastest)

Perfect for local development and testing.

```bash
# Clone the repository
git clone https://github.com/Dhananjaiah/kubernetes-course-2026.git
cd kubernetes-course-2026/microservices

# Start all services
docker-compose up -d

# Wait for services to be ready (30-60 seconds)
docker-compose ps

# Check logs if needed
docker-compose logs -f

# Open in browser
open http://localhost:3000
```

### Testing the Application

```bash
# Create a product
curl -X POST http://localhost:3001/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro",
    "description": "Apple M2 Pro laptop",
    "price": 2499.99,
    "category": "Electronics",
    "stock": 25,
    "imageUrl": "https://example.com/macbook.jpg"
  }'

# Get all products
curl http://localhost:3001/api/products

# Register a user
curl -X POST http://localhost:3002/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepass123",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

### Stopping the Application

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (cleans all data)
docker-compose down -v
```

## Option 2: Kubernetes (Production-like)

### Using Minikube

```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Build images
cd kubernetes-course-2026/microservices
eval $(minikube docker-env)  # Use Minikube's Docker daemon

docker build -t product-service:latest ./product-service
docker build -t user-service:latest ./user-service
docker build -t order-service:latest ./order-service
docker build -t cart-service:latest ./cart-service
docker build -t frontend:latest ./frontend

# Deploy to Kubernetes
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/databases/
kubectl apply -f k8s/deployments/

# Wait for pods to be ready
kubectl get pods -w

# Access the application
minikube service frontend
```

### Using kind (Kubernetes in Docker)

```bash
# Create kind cluster
kind create cluster --name ecommerce

# Load images into kind
kind load docker-image product-service:latest --name ecommerce
kind load docker-image user-service:latest --name ecommerce
kind load docker-image order-service:latest --name ecommerce
kind load docker-image cart-service:latest --name ecommerce
kind load docker-image frontend:latest --name ecommerce

# Deploy to Kubernetes
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/databases/
kubectl apply -f k8s/deployments/

# Port forward to access
kubectl port-forward service/frontend 3000:80
# Open http://localhost:3000
```

### Using Cloud Provider (GKE, EKS, AKS)

```bash
# Build and push images to container registry
# Example for Docker Hub:
docker build -t yourusername/product-service:latest ./product-service
docker push yourusername/product-service:latest
# Repeat for other services...

# Update image names in k8s/deployments/*.yaml to use your registry

# Deploy to Kubernetes
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/databases/
kubectl apply -f k8s/deployments/

# Get external IP
kubectl get service frontend
```

## Verifying the Deployment

### Docker Compose

```bash
# Check all services are running
docker-compose ps

# Check service health
curl http://localhost:3000/health

# View service logs
docker-compose logs frontend
docker-compose logs product-service
```

### Kubernetes

```bash
# Check all pods are running
kubectl get pods

# Check services
kubectl get services

# Check pod logs
kubectl logs -l app=frontend
kubectl logs -l app=product-service

# Check service health
kubectl exec -it $(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- wget -q -O- http://localhost:3000/health
```

## Common Issues

### Docker Compose Issues

**Services not starting:**
```bash
# Check Docker resources (need at least 4GB RAM)
docker system info

# Restart Docker Desktop
# Then: docker-compose up -d
```

**Port conflicts:**
```bash
# Check if ports are already in use
lsof -i :3000  # Frontend
lsof -i :3001  # Product service
# Kill the process or change ports in docker-compose.yml
```

### Kubernetes Issues

**Pods stuck in Pending:**
```bash
# Check events
kubectl describe pod <pod-name>

# Common causes:
# - Insufficient resources
# - PVC not bound
# - Image pull errors
```

**Services not accessible:**
```bash
# For Minikube, use:
minikube service frontend

# For port-forward:
kubectl port-forward service/frontend 3000:80
```

**Database connection errors:**
```bash
# Check database pods are running
kubectl get pods -l tier=database

# Check logs
kubectl logs -l app=mongodb
kubectl logs -l app=postgres
```

## What's Next?

1. **Explore the API**: Use the endpoints documented in [README.md](README.md)
2. **Read the Architecture**: Check [ARCHITECTURE.md](ARCHITECTURE.md) for design details
3. **Scale Services**: Try scaling replicas:
   ```bash
   # Docker Compose
   docker-compose up -d --scale product-service=3
   
   # Kubernetes
   kubectl scale deployment product-service --replicas=3
   ```
4. **Add Monitoring**: Install Prometheus and Grafana
5. **Try Ingress**: Deploy with ingress for proper routing

## Getting Help

- Check [README.md](README.md) for detailed documentation
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Open an issue on GitHub for problems
- Check service logs for error messages

## Clean Up

### Docker Compose
```bash
docker-compose down -v
```

### Kubernetes
```bash
kubectl delete -f k8s/deployments/
kubectl delete -f k8s/databases/
kubectl delete -f k8s/secrets/

# For Minikube
minikube delete

# For kind
kind delete cluster --name ecommerce
```

---

**Ready to learn Kubernetes with a real-world application! 🚀**
