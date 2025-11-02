# Frontend Service

API Gateway and frontend for the e-commerce microservices application.

## Features

- API Gateway routing to all backend services
- Service health monitoring
- Static web interface
- CORS enabled for external access
- Health check and readiness endpoints

## Architecture

The frontend service acts as an API Gateway, routing requests to:
- Product Service (port 3001)
- User Service (port 3002)
- Order Service (port 3003)
- Cart Service (port 3004)

## API Endpoints

### Health & Readiness
- `GET /health` - Health check endpoint (checks all services)
- `GET /ready` - Readiness probe endpoint

### Products (proxied to Product Service)
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get single product

### Users (proxied to User Service)
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - Login user
- `GET /api/users/profile` - Get user profile

### Cart (proxied to Cart Service)
- `GET /api/cart/:userId` - Get user cart
- `POST /api/cart/:userId/items` - Add item to cart
- `DELETE /api/cart/:userId/items/:productId` - Remove item from cart

### Orders (proxied to Order Service)
- `POST /api/orders` - Create new order
- `GET /api/orders/user/:userId` - Get user orders
- `GET /api/orders/:id` - Get order by ID

## Running Locally

```bash
# Install dependencies
npm install

# Set environment variables
cp .env.example .env

# Start the service
npm start

# For development with auto-reload
npm run dev
```

## Running with Docker

```bash
# Build image
docker build -t frontend:latest .

# Run container
docker run -p 3000:3000 \
  -e PRODUCT_SERVICE_URL=http://product-service:3001 \
  -e USER_SERVICE_URL=http://user-service:3002 \
  -e ORDER_SERVICE_URL=http://order-service:3003 \
  -e CART_SERVICE_URL=http://cart-service:3004 \
  frontend:latest
```

## Environment Variables

- `PORT` - Service port (default: 3000)
- `PRODUCT_SERVICE_URL` - Product service URL
- `USER_SERVICE_URL` - User service URL
- `ORDER_SERVICE_URL` - Order service URL
- `CART_SERVICE_URL` - Cart service URL

## Accessing the Web Interface

Once running, open your browser to:
```
http://localhost:3000
```

The web interface provides information about the microservices architecture and available API endpoints.
