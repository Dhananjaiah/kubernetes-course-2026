# Product Service

Product catalog microservice for the e-commerce application.

## Features

- CRUD operations for products
- Product search and filtering
- Stock management
- MongoDB for data persistence
- Health check and readiness endpoints

## API Endpoints

### Health & Readiness
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness probe endpoint

### Products
- `GET /api/products` - Get all products (supports filtering)
  - Query params: `category`, `minPrice`, `maxPrice`
- `GET /api/products/:id` - Get single product
- `POST /api/products` - Create new product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `PATCH /api/products/:id/stock` - Update product stock

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
docker build -t product-service:latest .

# Run container
docker run -p 3001:3001 -e MONGODB_URI=mongodb://host.docker.internal:27017/products product-service:latest
```

## Environment Variables

- `PORT` - Service port (default: 3001)
- `MONGODB_URI` - MongoDB connection string

## Example Product Object

```json
{
  "name": "Laptop",
  "description": "High-performance laptop",
  "price": 999.99,
  "category": "Electronics",
  "stock": 50,
  "imageUrl": "https://example.com/laptop.jpg"
}
```
