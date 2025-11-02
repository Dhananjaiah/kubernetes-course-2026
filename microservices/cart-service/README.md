# Cart Service

Shopping cart microservice using Redis for fast, session-based storage.

## Features

- Add/remove items to cart
- Update item quantities
- Redis for fast cart storage
- Integration with Product Service
- Automatic cart expiry (7 days)
- Health check and readiness endpoints

## API Endpoints

### Health & Readiness
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness probe endpoint

### Cart Management
- `GET /api/cart/:userId` - Get cart for user
- `POST /api/cart/:userId/items` - Add item to cart
- `PUT /api/cart/:userId/items/:productId` - Update item quantity
- `DELETE /api/cart/:userId/items/:productId` - Remove item from cart
- `DELETE /api/cart/:userId` - Clear entire cart

## Running Locally

```bash
# Install dependencies
npm install

# Set environment variables
cp .env.example .env

# Start Redis
docker run -d -p 6379:6379 redis:7-alpine

# Start the service
npm start

# For development with auto-reload
npm run dev
```

## Running with Docker

```bash
# Build image
docker build -t cart-service:latest .

# Run container
docker run -p 3004:3004 \
  -e REDIS_URL=redis://host.docker.internal:6379 \
  -e PRODUCT_SERVICE_URL=http://product-service:3001 \
  cart-service:latest
```

## Environment Variables

- `PORT` - Service port (default: 3004)
- `REDIS_URL` - Redis connection URL
- `PRODUCT_SERVICE_URL` - Product service URL

## Example Add Item to Cart

```json
{
  "product_id": "507f1f77bcf86cd799439011",
  "quantity": 2
}
```

## Example Update Quantity

```json
{
  "quantity": 5
}
```

## Cart Data Structure

```json
{
  "items": [
    {
      "product_id": "507f1f77bcf86cd799439011",
      "name": "Laptop",
      "price": 999.99,
      "quantity": 2,
      "imageUrl": "https://example.com/laptop.jpg"
    }
  ],
  "total": 1999.98
}
```

## Service Dependencies

This service communicates with:
- **Product Service** - To fetch product details
- **Redis** - For cart storage
