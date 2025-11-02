# E-Commerce Microservices Application

A production-ready microservices architecture for an e-commerce platform, designed to demonstrate real-world Kubernetes deployment patterns.

## 🏗️ Architecture Overview

This application consists of 5 microservices and 3 databases:

### Microservices

1. **Frontend Service** (Port 3000)
   - API Gateway that routes to all backend services
   - Serves static web interface
   - Health monitoring of all services
   - Technology: Node.js + Express

2. **Product Service** (Port 3001)
   - Product catalog management
   - Inventory and stock management
   - CRUD operations for products
   - Technology: Node.js + MongoDB

3. **User Service** (Port 3002)
   - User authentication and registration
   - JWT-based authentication
   - Profile management
   - Technology: Node.js + PostgreSQL

4. **Order Service** (Port 3003)
   - Order processing and management
   - Order lifecycle tracking
   - Integration with Product service for stock
   - Technology: Node.js + PostgreSQL

5. **Cart Service** (Port 3004)
   - Shopping cart management
   - Fast session-based storage
   - Automatic cart expiry
   - Technology: Node.js + Redis

### Databases

- **MongoDB** - Product catalog storage
- **PostgreSQL** - User and order data
- **Redis** - Cart and session cache

## 🚀 Quick Start

**Want to get started quickly?** See [QUICKSTART.md](QUICKSTART.md) for detailed step-by-step instructions.

### Prerequisites

- Docker & Docker Compose
- Kubernetes cluster (Minikube, kind, or cloud provider)
- kubectl configured
- (Optional) Helm for chart-based deployment

### Super Quick Start (Automated)

```bash
# For Kubernetes deployment
./deploy.sh

# To clean up
./cleanup.sh
```

### Option 1: Docker Compose (Development)

```bash
# Clone the repository
git clone https://github.com/Dhananjaiah/kubernetes-course-2026.git
cd kubernetes-course-2026/microservices

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Access the application
open http://localhost:3000
```

### Option 2: Kubernetes (Production-like)

```bash
# Navigate to microservices directory
cd kubernetes-course-2026/microservices

# Build Docker images for all services
docker build -t product-service:latest ./product-service
docker build -t user-service:latest ./user-service
docker build -t order-service:latest ./order-service
docker build -t cart-service:latest ./cart-service
docker build -t frontend:latest ./frontend

# Apply Kubernetes manifests
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/databases/
kubectl apply -f k8s/deployments/

# Wait for all pods to be ready
kubectl get pods -w

# Access the application
# For Minikube:
minikube service frontend

# For LoadBalancer:
kubectl get service frontend
# Visit the EXTERNAL-IP
```

### Option 3: With Ingress

```bash
# Install nginx ingress controller (if not already installed)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Apply all manifests including ingress
kubectl apply -f k8s/secrets/
kubectl apply -f k8s/databases/
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/ingress/

# Add to /etc/hosts
echo "$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}') ecommerce.local" | sudo tee -a /etc/hosts

# Access the application
open http://ecommerce.local
```

## 📊 Architecture Diagram

```
                                    ┌─────────────┐
                                    │   Internet  │
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │   Ingress   │
                                    │  Controller │
                                    └──────┬──────┘
                                           │
                          ┌────────────────┼────────────────┐
                          │                │                │
                    ┌─────▼─────┐    ┌────▼────┐    ┌─────▼─────┐
                    │  Frontend │    │ Product │    │   User    │
                    │  Service  │───▶│ Service │    │  Service  │
                    │  (3000)   │    │ (3001)  │    │  (3002)   │
                    └─────┬─────┘    └────┬────┘    └─────┬─────┘
                          │               │               │
                    ┌─────▼─────┐    ┌────▼────┐    ┌─────▼─────┐
                    │   Cart    │    │ MongoDB │    │ PostgreSQL│
                    │  Service  │    │         │    │           │
                    │  (3004)   │    │         │    │           │
                    └─────┬─────┘    └─────────┘    └─────┬─────┘
                          │                               │
                    ┌─────▼─────┐                   ┌─────▼─────┐
                    │   Redis   │                   │   Order   │
                    │           │                   │  Service  │
                    │           │                   │  (3003)   │
                    └───────────┘                   └───────────┘
```

## 🔌 API Endpoints

### Frontend (API Gateway)
- `GET /` - Web interface
- `GET /health` - Health check for all services

### Product Service
- `GET /api/products` - List all products
- `GET /api/products/:id` - Get product details
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `PATCH /api/products/:id/stock` - Update stock

### User Service
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - Login user
- `GET /api/users/profile` - Get user profile (requires JWT)
- `PUT /api/users/profile` - Update profile (requires JWT)

### Cart Service
- `GET /api/cart/:userId` - Get user cart
- `POST /api/cart/:userId/items` - Add item to cart
- `PUT /api/cart/:userId/items/:productId` - Update quantity
- `DELETE /api/cart/:userId/items/:productId` - Remove item
- `DELETE /api/cart/:userId` - Clear cart

### Order Service
- `POST /api/orders` - Create new order
- `GET /api/orders` - Get all orders (admin)
- `GET /api/orders/:id` - Get order by ID
- `GET /api/orders/user/:userId` - Get user orders
- `PATCH /api/orders/:id/status` - Update order status

## 🛠️ Technology Stack

### Backend Services
- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Authentication**: JWT (jsonwebtoken)
- **Password Hashing**: bcryptjs

### Databases
- **MongoDB 7** - NoSQL for product catalog
- **PostgreSQL 15** - Relational DB for users/orders
- **Redis 7** - In-memory cache for cart

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Service Mesh**: Native K8s networking
- **Load Balancing**: Kubernetes Services + Ingress

## 📁 Project Structure

```
microservices/
├── frontend/                    # Frontend API Gateway service
│   ├── index.js                # Main application file
│   ├── public/                 # Static web files
│   ├── Dockerfile             # Container image definition
│   └── package.json           # Dependencies
│
├── product-service/            # Product catalog service
│   ├── index.js               # Main application file
│   ├── Dockerfile             # Container image definition
│   └── package.json           # Dependencies
│
├── user-service/               # User authentication service
│   ├── index.js               # Main application file
│   ├── Dockerfile             # Container image definition
│   └── package.json           # Dependencies
│
├── order-service/              # Order management service
│   ├── index.js               # Main application file
│   ├── Dockerfile             # Container image definition
│   └── package.json           # Dependencies
│
├── cart-service/               # Shopping cart service
│   ├── index.js               # Main application file
│   ├── Dockerfile             # Container image definition
│   └── package.json           # Dependencies
│
├── k8s/                        # Kubernetes manifests
│   ├── databases/             # Database deployments
│   │   ├── mongodb-deployment.yaml
│   │   ├── postgres-deployment.yaml
│   │   └── redis-deployment.yaml
│   ├── deployments/           # Service deployments
│   │   ├── product-service.yaml
│   │   ├── user-service.yaml
│   │   ├── order-service.yaml
│   │   ├── cart-service.yaml
│   │   └── frontend.yaml
│   ├── secrets/               # Secrets
│   │   ├── postgres-secret.yaml
│   │   └── jwt-secret.yaml
│   └── ingress/               # Ingress configuration
│       └── ingress.yaml
│
├── docker-compose.yml          # Local development setup
└── README.md                   # This file
```

## 🔒 Security Features

1. **JWT Authentication** - Secure user authentication
2. **Password Hashing** - bcrypt for password storage
3. **Secrets Management** - Kubernetes secrets for sensitive data
4. **Non-root Containers** - All containers run as non-root user
5. **Resource Limits** - CPU and memory limits on all pods
6. **Health Checks** - Liveness and readiness probes

## 📈 Scalability Features

1. **Horizontal Pod Autoscaling** - Ready for HPA configuration
2. **Multiple Replicas** - Each service runs 2+ replicas
3. **Load Balancing** - Native Kubernetes service load balancing
4. **Stateless Services** - All services are stateless (except databases)
5. **Database Persistence** - PersistentVolumeClaims for data
6. **Caching Layer** - Redis for high-performance caching

## 🧪 Testing the Application

### Test Product Service

```bash
# Create a product
curl -X POST http://localhost:3001/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "category": "Electronics",
    "stock": 50
  }'

# Get all products
curl http://localhost:3001/api/products
```

### Test User Service

```bash
# Register a user
curl -X POST http://localhost:3002/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "first_name": "John",
    "last_name": "Doe"
  }'

# Login
curl -X POST http://localhost:3002/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

### Test Cart Service

```bash
# Add item to cart
curl -X POST http://localhost:3004/api/cart/1/items \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "PRODUCT_ID_HERE",
    "quantity": 2
  }'

# Get cart
curl http://localhost:3004/api/cart/1
```

### Test Order Service

```bash
# Create order
curl -X POST http://localhost:3003/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "items": [
      {
        "product_id": "PRODUCT_ID_HERE",
        "quantity": 2
      }
    ]
  }'

# Get user orders
curl http://localhost:3003/api/orders/user/1
```

## 🔧 Troubleshooting

### Services not starting

```bash
# Check pod status
kubectl get pods

# View pod logs
kubectl logs <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>
```

### Database connection issues

```bash
# Check database pods
kubectl get pods -l tier=database

# Test database connectivity
kubectl exec -it <database-pod> -- bash
```

### Service discovery issues

```bash
# List all services
kubectl get services

# Check service endpoints
kubectl get endpoints
```

## 📚 Learning Objectives

This project demonstrates:

1. **Microservices Architecture** - Decomposing monolith into services
2. **Service Communication** - HTTP REST APIs between services
3. **Database per Service** - Independent data stores
4. **API Gateway Pattern** - Single entry point for clients
5. **Health Checks** - Kubernetes liveness/readiness probes
6. **Secrets Management** - Secure configuration
7. **Persistent Storage** - StatefulSets and PVCs
8. **Service Discovery** - Kubernetes DNS
9. **Load Balancing** - Service-level load balancing
10. **Container Best Practices** - Multi-stage builds, non-root users

## 🚀 Production Considerations

Before deploying to production, consider:

1. **Change default secrets** - Update all passwords and JWT secrets
2. **Add TLS/SSL** - Enable HTTPS with certificates
3. **Setup monitoring** - Prometheus + Grafana
4. **Add logging** - ELK stack or similar
5. **Implement tracing** - Jaeger or Zipkin
6. **Setup CI/CD** - Automate builds and deployments
7. **Add rate limiting** - Protect APIs from abuse
8. **Implement circuit breakers** - Handle service failures
9. **Setup backups** - Regular database backups
10. **Configure HPA** - Auto-scaling based on metrics

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- Add more microservices (payment, notification, etc.)
- Implement service mesh (Istio/Linkerd)
- Add API documentation (Swagger/OpenAPI)
- Create Helm charts
- Add end-to-end tests
- Implement event-driven architecture
- Add GraphQL API layer

## 📝 License

This project is for educational purposes as part of the Kubernetes Course 2026.

## 🙏 Acknowledgments

Built to demonstrate real-world microservices patterns for Kubernetes learning.

---

**Happy Learning! 🚀**

For questions or issues, please open a GitHub issue in the main repository.
