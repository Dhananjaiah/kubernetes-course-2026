#!/bin/bash

# Sample Data Seeding Script
# This script adds sample products and users to the application

set -e

# Detect service URL based on environment
if kubectl get service frontend &> /dev/null; then
    # Check if running in Minikube
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        BASE_URL="http://$(minikube ip):$(kubectl get service frontend -o jsonpath='{.spec.ports[0].nodePort}')"
    else
        # Check for LoadBalancer
        EXTERNAL_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            BASE_URL="http://${EXTERNAL_IP}"
        else
            echo "⚠️  Cannot auto-detect service URL. Using port-forward..."
            kubectl port-forward service/frontend 3000:80 &
            PF_PID=$!
            sleep 3
            BASE_URL="http://localhost:3000"
        fi
    fi
else
    # Default to localhost for Docker Compose
    BASE_URL="http://localhost:3000"
fi

echo "🌱 Seeding sample data..."
echo "📍 Using API: ${BASE_URL}"
echo ""

# Sample Products
echo "📦 Adding sample products..."

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "MacBook Pro 16\"",
    "description": "Apple M2 Pro chip, 16GB RAM, 512GB SSD",
    "price": 2499.99,
    "category": "Electronics",
    "stock": 25,
    "imageUrl": "https://via.placeholder.com/300x200?text=MacBook+Pro"
  }'
echo "✓ Added MacBook Pro"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "iPhone 15 Pro",
    "description": "6.1-inch display, A17 Pro chip, 256GB",
    "price": 1199.99,
    "category": "Electronics",
    "stock": 50,
    "imageUrl": "https://via.placeholder.com/300x200?text=iPhone+15"
  }'
echo "✓ Added iPhone 15 Pro"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "AirPods Pro",
    "description": "Active Noise Cancellation, Spatial Audio",
    "price": 249.99,
    "category": "Electronics",
    "stock": 100,
    "imageUrl": "https://via.placeholder.com/300x200?text=AirPods+Pro"
  }'
echo "✓ Added AirPods Pro"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "Apple Watch Series 9",
    "description": "GPS, 45mm, Midnight Aluminum Case",
    "price": 429.99,
    "category": "Electronics",
    "stock": 75,
    "imageUrl": "https://via.placeholder.com/300x200?text=Apple+Watch"
  }'
echo "✓ Added Apple Watch"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "iPad Air",
    "description": "10.9-inch display, M1 chip, 64GB",
    "price": 599.99,
    "category": "Electronics",
    "stock": 40,
    "imageUrl": "https://via.placeholder.com/300x200?text=iPad+Air"
  }'
echo "✓ Added iPad Air"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "Magic Keyboard",
    "description": "Wireless, Rechargeable, for Mac",
    "price": 99.99,
    "category": "Accessories",
    "stock": 150,
    "imageUrl": "https://via.placeholder.com/300x200?text=Magic+Keyboard"
  }'
echo "✓ Added Magic Keyboard"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "Magic Mouse",
    "description": "Wireless, Rechargeable, Multi-Touch Surface",
    "price": 79.99,
    "category": "Accessories",
    "stock": 120,
    "imageUrl": "https://via.placeholder.com/300x200?text=Magic+Mouse"
  }'
echo "✓ Added Magic Mouse"

curl -X POST "${BASE_URL}/api/products" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "name": "USB-C Cable",
    "description": "2-meter charging cable",
    "price": 19.99,
    "category": "Accessories",
    "stock": 200,
    "imageUrl": "https://via.placeholder.com/300x200?text=USB-C+Cable"
  }'
echo "✓ Added USB-C Cable"

echo ""
echo "👤 Adding sample users..."

curl -X POST "${BASE_URL}/api/users/register" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "email": "john.doe@example.com",
    "password": "password123",
    "first_name": "John",
    "last_name": "Doe"
  }'
echo "✓ Added John Doe (john.doe@example.com)"

curl -X POST "${BASE_URL}/api/users/register" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "email": "jane.smith@example.com",
    "password": "password123",
    "first_name": "Jane",
    "last_name": "Smith"
  }'
echo "✓ Added Jane Smith (jane.smith@example.com)"

curl -X POST "${BASE_URL}/api/users/register" \
  -H "Content-Type: application/json" \
  -s -o /dev/null \
  -d '{
    "email": "admin@example.com",
    "password": "admin123",
    "first_name": "Admin",
    "last_name": "User"
  }'
echo "✓ Added Admin User (admin@example.com)"

echo ""
echo "✅ Sample data seeding complete!"
echo ""
echo "You can now:"
echo "  • View products: ${BASE_URL}/api/products"
echo "  • Login with: john.doe@example.com / password123"
echo "  • Or with: admin@example.com / admin123"
echo ""
echo "📖 Test credentials:"
echo "   Email: john.doe@example.com"
echo "   Password: password123"
echo ""

# Clean up port-forward if we started it
if [ -n "$PF_PID" ]; then
    kill $PF_PID 2>/dev/null || true
fi
