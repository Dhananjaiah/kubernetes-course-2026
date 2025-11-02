# Microservices Architecture

## System Architecture

This document describes the architecture of the e-commerce microservices application.

## Overview

The application follows a microservices architecture pattern with the following characteristics:

- **Service Independence**: Each service can be developed, deployed, and scaled independently
- **Database per Service**: Each service has its own database to ensure loose coupling
- **API Gateway**: Frontend service acts as an API gateway for client requests
- **Service Discovery**: Kubernetes DNS for service-to-service communication
- **Container Orchestration**: Kubernetes for deployment and management

## Components

### 1. Frontend Service (API Gateway)

**Purpose**: Entry point for all client requests, routes to appropriate backend services

**Technology**: Node.js + Express

**Responsibilities**:
- Route API requests to backend services
- Serve static web interface
- Monitor health of all backend services
- CORS handling

**Port**: 3000

**Dependencies**:
- All backend services

### 2. Product Service

**Purpose**: Manage product catalog and inventory

**Technology**: Node.js + Express + MongoDB

**Responsibilities**:
- CRUD operations for products
- Product search and filtering
- Stock management
- Product categorization

**Port**: 3001

**Database**: MongoDB (products database)

**API Endpoints**:
- GET /api/products - List products
- GET /api/products/:id - Get product details
- POST /api/products - Create product
- PUT /api/products/:id - Update product
- DELETE /api/products/:id - Delete product
- PATCH /api/products/:id/stock - Update stock

### 3. User Service

**Purpose**: User authentication and profile management

**Technology**: Node.js + Express + PostgreSQL + JWT

**Responsibilities**:
- User registration
- User authentication (login)
- JWT token generation
- Profile management
- Password hashing

**Port**: 3002

**Database**: PostgreSQL (users database)

**Security**:
- Passwords hashed with bcrypt
- JWT for authentication
- Token expiry: 24 hours

**API Endpoints**:
- POST /api/users/register - Register user
- POST /api/users/login - Login user
- GET /api/users/profile - Get profile (protected)
- PUT /api/users/profile - Update profile (protected)

### 4. Order Service

**Purpose**: Order processing and management

**Technology**: Node.js + Express + PostgreSQL

**Responsibilities**:
- Order creation
- Order lifecycle management
- Integration with Product service for stock validation
- Order history tracking

**Port**: 3003

**Database**: PostgreSQL (orders database)

**Dependencies**:
- Product Service (for stock validation)

**API Endpoints**:
- POST /api/orders - Create order
- GET /api/orders - Get all orders
- GET /api/orders/:id - Get order by ID
- GET /api/orders/user/:userId - Get user orders
- PATCH /api/orders/:id/status - Update order status

**Order Status Values**:
- pending
- processing
- shipped
- delivered
- cancelled

### 5. Cart Service

**Purpose**: Shopping cart management

**Technology**: Node.js + Express + Redis

**Responsibilities**:
- Add/remove items to cart
- Update item quantities
- Cart persistence
- Automatic cart expiry (7 days)

**Port**: 3004

**Cache**: Redis

**Dependencies**:
- Product Service (for product details)

**API Endpoints**:
- GET /api/cart/:userId - Get cart
- POST /api/cart/:userId/items - Add item
- PUT /api/cart/:userId/items/:productId - Update quantity
- DELETE /api/cart/:userId/items/:productId - Remove item
- DELETE /api/cart/:userId - Clear cart

## Data Flow

### User Registration Flow

```
Client → Frontend → User Service → PostgreSQL
                         ↓
                    JWT Token
                         ↓
                      Client
```

### Product Purchase Flow

```
1. Browse Products:
   Client → Frontend → Product Service → MongoDB

2. Add to Cart:
   Client → Frontend → Cart Service → Redis
                            ↓
                     Product Service (validate)

3. Checkout:
   Client → Frontend → Order Service → PostgreSQL
                            ↓
                     Product Service (update stock)
                            ↓
                     Cart Service (clear cart)
```

## Service Communication

### Synchronous Communication (HTTP/REST)

All services communicate via HTTP REST APIs:

- **Frontend → Backend Services**: HTTP requests through Kubernetes service discovery
- **Order Service → Product Service**: HTTP for stock validation
- **Cart Service → Product Service**: HTTP for product details

### Service Discovery

Services discover each other using Kubernetes DNS:
- `http://product-service:3001`
- `http://user-service:3002`
- `http://order-service:3003`
- `http://cart-service:3004`

## Data Storage

### MongoDB (Product Service)

**Purpose**: Store product catalog

**Collections**:
- products: Product information, prices, stock

**Persistence**: PersistentVolumeClaim (5Gi)

### PostgreSQL (User & Order Services)

**Purpose**: Store user and order data

**Databases**:
- users: User accounts and profiles
- orders: Orders and order items

**Tables**:
- users (id, email, password, first_name, last_name)
- orders (id, user_id, total_amount, status)
- order_items (id, order_id, product_id, quantity, price)

**Persistence**: PersistentVolumeClaim (5Gi)

### Redis (Cart Service)

**Purpose**: Fast cart storage

**Data Structure**:
- Key: `cart:{userId}`
- Value: JSON cart object
- TTL: 7 days

**No Persistence**: In-memory cache

## Security Architecture

### Authentication

1. User logs in via User Service
2. User Service validates credentials
3. JWT token generated and returned
4. Client includes token in subsequent requests
5. Protected endpoints validate JWT

### Secrets Management

Kubernetes Secrets store sensitive data:
- Database passwords
- JWT secret keys

### Network Security

- Services communicate within Kubernetes cluster network
- Only Frontend service exposed externally
- Database services are ClusterIP (internal only)

## Scalability

### Horizontal Scaling

All services can scale horizontally:
- Frontend: 2 replicas (can scale to more)
- Product Service: 2 replicas
- User Service: 2 replicas
- Order Service: 2 replicas
- Cart Service: 2 replicas

### Load Balancing

Kubernetes Services provide load balancing:
- Round-robin distribution
- Automatic health checking
- Failed pod removal

### Database Scaling

- MongoDB: Can be configured as ReplicaSet
- PostgreSQL: Can use read replicas
- Redis: Can use Redis Cluster

## Observability

### Health Checks

All services implement:
- **Liveness Probe**: `/health` - Is service alive?
- **Readiness Probe**: `/ready` - Is service ready to receive traffic?

### Monitoring Points

- Service health endpoints
- Database connection status
- Response times
- Error rates

## Deployment Architecture

### Container Images

Each service has its own Docker image:
- Base: node:18-alpine
- Non-root user: nodejs (uid: 1001)
- Health check built-in

### Kubernetes Resources

- **Deployments**: Service application instances
- **Services**: Network access to pods
- **PersistentVolumeClaims**: Database storage
- **Secrets**: Sensitive configuration
- **Ingress**: External HTTP access

## Design Patterns

### 1. API Gateway Pattern

Frontend service acts as API Gateway:
- Single entry point for clients
- Routes requests to appropriate services
- Aggregates service health

### 2. Database per Service

Each service owns its database:
- Product Service → MongoDB
- User Service → PostgreSQL (users db)
- Order Service → PostgreSQL (orders db)
- Cart Service → Redis

### 3. Circuit Breaker (Ready for Implementation)

Services handle downstream failures gracefully with error responses.

### 4. Health Check Pattern

All services expose health endpoints for Kubernetes probes.

## Technology Choices

### Why Node.js?

- Fast development
- Great for I/O-bound operations
- Large ecosystem
- JavaScript everywhere

### Why MongoDB for Products?

- Flexible schema for product attributes
- Fast reads for catalog browsing
- Good for unstructured data

### Why PostgreSQL for Users/Orders?

- ACID compliance for transactions
- Strong consistency for financial data
- Relational integrity

### Why Redis for Cart?

- Extremely fast (in-memory)
- Built-in TTL for automatic expiry
- Perfect for session data

## Future Enhancements

1. **Event-Driven Architecture**: Add message queue (RabbitMQ/Kafka)
2. **Service Mesh**: Implement Istio for advanced traffic management
3. **API Documentation**: Add Swagger/OpenAPI specs
4. **Monitoring**: Prometheus + Grafana
5. **Logging**: ELK stack (Elasticsearch, Logstash, Kibana)
6. **Tracing**: Distributed tracing with Jaeger
7. **CI/CD**: Automated pipelines
8. **Rate Limiting**: API rate limiting
9. **Caching**: CDN for static assets
10. **Payment Service**: Add payment processing

## Conclusion

This architecture demonstrates core microservices principles:
- Service independence
- Loose coupling
- Technology diversity
- Scalability
- Resilience

Perfect for learning Kubernetes and microservices patterns!
