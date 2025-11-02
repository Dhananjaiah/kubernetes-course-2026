# Order Service

Order management microservice for the e-commerce application.

## Features

- Order creation and management
- Integration with Product Service for stock validation
- Order status tracking
- PostgreSQL for data persistence
- Transaction support for data consistency
- Health check and readiness endpoints

## API Endpoints

### Health & Readiness
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness probe endpoint

### Orders
- `POST /api/orders` - Create new order
- `GET /api/orders` - Get all orders (admin)
- `GET /api/orders/:id` - Get order by ID
- `GET /api/orders/user/:userId` - Get orders for specific user
- `PATCH /api/orders/:id/status` - Update order status

## Order Status Values

- `pending` - Order created
- `processing` - Order being processed
- `shipped` - Order shipped
- `delivered` - Order delivered
- `cancelled` - Order cancelled

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
docker build -t order-service:latest .

# Run container
docker run -p 3003:3003 \
  -e DB_HOST=host.docker.internal \
  -e PRODUCT_SERVICE_URL=http://product-service:3001 \
  order-service:latest
```

## Environment Variables

- `PORT` - Service port (default: 3003)
- `DB_HOST` - PostgreSQL host
- `DB_PORT` - PostgreSQL port
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `PRODUCT_SERVICE_URL` - Product service URL

## Example Order Creation

```json
{
  "user_id": 1,
  "items": [
    {
      "product_id": "507f1f77bcf86cd799439011",
      "quantity": 2
    },
    {
      "product_id": "507f1f77bcf86cd799439012",
      "quantity": 1
    }
  ]
}
```

## Service Dependencies

This service communicates with:
- **Product Service** - To validate products and update stock
