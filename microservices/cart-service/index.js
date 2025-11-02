const express = require('express');
const redis = require('redis');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3004;
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3001';
const REDIS_URL = process.env.REDIS_URL || 'redis://redis:6379';

// Middleware
app.use(cors());
app.use(express.json());

// Redis Client
let redisClient;

(async () => {
  redisClient = redis.createClient({
    url: REDIS_URL
  });

  redisClient.on('error', (err) => console.error('❌ Redis Client Error:', err));
  redisClient.on('connect', () => console.log('✅ Connected to Redis'));

  await redisClient.connect();
})();

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const isRedisReady = redisClient.isReady;
    res.status(200).json({
      status: 'UP',
      service: 'cart-service',
      timestamp: new Date().toISOString(),
      redis: isRedisReady ? 'connected' : 'disconnected'
    });
  } catch (error) {
    res.status(503).json({
      status: 'DOWN',
      service: 'cart-service',
      timestamp: new Date().toISOString()
    });
  }
});

// Readiness check endpoint
app.get('/ready', async (req, res) => {
  try {
    const isReady = redisClient.isReady;
    if (isReady) {
      res.status(200).json({ status: 'ready' });
    } else {
      res.status(503).json({ status: 'not ready' });
    }
  } catch (error) {
    res.status(503).json({ status: 'not ready' });
  }
});

// Get cart for user
app.get('/api/cart/:userId', async (req, res) => {
  try {
    const cartData = await redisClient.get(`cart:${req.params.userId}`);
    
    if (!cartData) {
      return res.json({ success: true, data: { items: [], total: 0 } });
    }

    const cart = JSON.parse(cartData);
    res.json({ success: true, data: cart });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Add item to cart
app.post('/api/cart/:userId/items', async (req, res) => {
  const { product_id, quantity } = req.body;

  if (!product_id || !quantity || quantity < 1) {
    return res.status(400).json({ success: false, error: 'Product ID and valid quantity required' });
  }

  try {
    // Fetch product details from product service
    const response = await axios.get(`${PRODUCT_SERVICE_URL}/api/products/${product_id}`);
    const product = response.data.data;

    // Get current cart
    const cartData = await redisClient.get(`cart:${req.params.userId}`);
    let cart = cartData ? JSON.parse(cartData) : { items: [], total: 0 };

    // Check if product already in cart
    const existingItemIndex = cart.items.findIndex(item => item.product_id === product_id);

    if (existingItemIndex >= 0) {
      // Update quantity
      cart.items[existingItemIndex].quantity += quantity;
    } else {
      // Add new item
      cart.items.push({
        product_id: product._id,
        name: product.name,
        price: product.price,
        quantity: quantity,
        imageUrl: product.imageUrl
      });
    }

    // Recalculate total
    cart.total = cart.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    // Save cart to Redis with 7 days expiry
    await redisClient.setEx(`cart:${req.params.userId}`, 7 * 24 * 60 * 60, JSON.stringify(cart));

    res.json({ success: true, data: cart });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update item quantity in cart
app.put('/api/cart/:userId/items/:productId', async (req, res) => {
  const { quantity } = req.body;

  if (quantity === undefined || quantity < 0) {
    return res.status(400).json({ success: false, error: 'Valid quantity required' });
  }

  try {
    const cartData = await redisClient.get(`cart:${req.params.userId}`);
    
    if (!cartData) {
      return res.status(404).json({ success: false, error: 'Cart not found' });
    }

    let cart = JSON.parse(cartData);
    const itemIndex = cart.items.findIndex(item => item.product_id === req.params.productId);

    if (itemIndex < 0) {
      return res.status(404).json({ success: false, error: 'Item not found in cart' });
    }

    if (quantity === 0) {
      // Remove item if quantity is 0
      cart.items.splice(itemIndex, 1);
    } else {
      // Update quantity
      cart.items[itemIndex].quantity = quantity;
    }

    // Recalculate total
    cart.total = cart.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    // Save updated cart
    await redisClient.setEx(`cart:${req.params.userId}`, 7 * 24 * 60 * 60, JSON.stringify(cart));

    res.json({ success: true, data: cart });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Remove item from cart
app.delete('/api/cart/:userId/items/:productId', async (req, res) => {
  try {
    const cartData = await redisClient.get(`cart:${req.params.userId}`);
    
    if (!cartData) {
      return res.status(404).json({ success: false, error: 'Cart not found' });
    }

    let cart = JSON.parse(cartData);
    cart.items = cart.items.filter(item => item.product_id !== req.params.productId);

    // Recalculate total
    cart.total = cart.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);

    // Save updated cart
    await redisClient.setEx(`cart:${req.params.userId}`, 7 * 24 * 60 * 60, JSON.stringify(cart));

    res.json({ success: true, data: cart });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Clear cart
app.delete('/api/cart/:userId', async (req, res) => {
  try {
    await redisClient.del(`cart:${req.params.userId}`);
    res.json({ success: true, message: 'Cart cleared' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Cart Service running on port ${PORT}`);
});
