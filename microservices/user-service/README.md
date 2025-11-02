# User Service

User authentication and management microservice for the e-commerce application.

## Features

- User registration and login
- JWT-based authentication
- Password hashing with bcrypt
- PostgreSQL for data persistence
- Profile management
- Health check and readiness endpoints

## API Endpoints

### Health & Readiness
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness probe endpoint

### Authentication
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - Login user

### User Management (Protected)
- `GET /api/users/profile` - Get user profile (requires JWT)
- `PUT /api/users/profile` - Update user profile (requires JWT)
- `GET /api/users` - Get all users (for testing)

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
docker build -t user-service:latest .

# Run container
docker run -p 3002:3002 \
  -e DB_HOST=host.docker.internal \
  -e DB_PASSWORD=yourpassword \
  user-service:latest
```

## Environment Variables

- `PORT` - Service port (default: 3002)
- `DB_HOST` - PostgreSQL host
- `DB_PORT` - PostgreSQL port
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `JWT_SECRET` - Secret key for JWT tokens

## Example User Registration

```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "first_name": "John",
  "last_name": "Doe"
}
```

## Example Login

```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

## Authentication

Protected endpoints require JWT token in Authorization header:

```
Authorization: Bearer <your-jwt-token>
```
