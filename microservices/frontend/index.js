const express = require('express');
const axios = require('axios');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Service URLs
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3001';
const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://user-service:3002';
const ORDER_SERVICE_URL = process.env.ORDER_SERVICE_URL || 'http://order-service:3003';
const CART_SERVICE_URL = process.env.CART_SERVICE_URL || 'http://cart-service:3004';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Health check endpoint
app.get('/health', async (req, res) => {
  const services = {
    product: false,
    user: false,
    order: false,
    cart: false
  };

  try {
    const productHealth = await axios.get(`${PRODUCT_SERVICE_URL}/health`);
    services.product = productHealth.data.status === 'UP';
  } catch (e) { /* service down */ }

  try {
    const userHealth = await axios.get(`${USER_SERVICE_URL}/health`);
    services.user = userHealth.data.status === 'UP';
  } catch (e) { /* service down */ }

  try {
    const orderHealth = await axios.get(`${ORDER_SERVICE_URL}/health`);
    services.order = orderHealth.data.status === 'UP';
  } catch (e) { /* service down */ }

  try {
    const cartHealth = await axios.get(`${CART_SERVICE_URL}/health`);
    services.cart = cartHealth.data.status === 'UP';
  } catch (e) { /* service down */ }

  const allHealthy = Object.values(services).every(status => status === true);

  res.status(allHealthy ? 200 : 503).json({
    status: allHealthy ? 'UP' : 'DEGRADED',
    service: 'frontend',
    timestamp: new Date().toISOString(),
    services
  });
});

// Readiness check endpoint
app.get('/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

// API Gateway - Product Service
app.get('/api/products', async (req, res) => {
  try {
    const response = await axios.get(`${PRODUCT_SERVICE_URL}/api/products`, { params: req.query });
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.get('/api/products/:id', async (req, res) => {
  try {
    const response = await axios.get(`${PRODUCT_SERVICE_URL}/api/products/${req.params.id}`);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

// API Gateway - User Service
app.post('/api/users/register', async (req, res) => {
  try {
    const response = await axios.post(`${USER_SERVICE_URL}/api/users/register`, req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.post('/api/users/login', async (req, res) => {
  try {
    const response = await axios.post(`${USER_SERVICE_URL}/api/users/login`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.get('/api/users/profile', async (req, res) => {
  try {
    const response = await axios.get(`${USER_SERVICE_URL}/api/users/profile`, {
      headers: { Authorization: req.headers.authorization }
    });
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

// API Gateway - Cart Service
app.get('/api/cart/:userId', async (req, res) => {
  try {
    const response = await axios.get(`${CART_SERVICE_URL}/api/cart/${req.params.userId}`);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.post('/api/cart/:userId/items', async (req, res) => {
  try {
    const response = await axios.post(`${CART_SERVICE_URL}/api/cart/${req.params.userId}/items`, req.body);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.delete('/api/cart/:userId/items/:productId', async (req, res) => {
  try {
    const response = await axios.delete(`${CART_SERVICE_URL}/api/cart/${req.params.userId}/items/${req.params.productId}`);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

// API Gateway - Order Service
app.post('/api/orders', async (req, res) => {
  try {
    const response = await axios.post(`${ORDER_SERVICE_URL}/api/orders`, req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.get('/api/orders/user/:userId', async (req, res) => {
  try {
    const response = await axios.get(`${ORDER_SERVICE_URL}/api/orders/user/${req.params.userId}`);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

app.get('/api/orders/:id', async (req, res) => {
  try {
    const response = await axios.get(`${ORDER_SERVICE_URL}/api/orders/${req.params.id}`);
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({ 
      success: false, 
      error: error.response?.data?.error || error.message 
    });
  }
});

// Serve index page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`🚀 Frontend Service (API Gateway) running on port ${PORT}`);
});
