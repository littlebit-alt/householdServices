const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const Sentry = require("@sentry/node");

const authRoutes = require('./routes/auth.routes');
const categoryRoutes = require('./routes/category.routes');
const serviceRoutes = require('./routes/service.routes');
const providerRoutes = require('./routes/provider.routes');
const bookingRoutes = require('./routes/booking.routes');
const addressRoutes = require('./routes/address.routes');
const reviewRoutes = require('./routes/review.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: '*',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests, please try again later.'
});
app.use(limiter);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ========== TEST SENTRY ENDPOINT (Remove after testing) ==========
app.get('/debug-sentry', (req, res) => {
  throw new Error('Test error from Sentry! Check your Sentry dashboard.');
});
// =================================================================

// ========== API ROUTES ==========
app.use('/api/auth', authRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/services', serviceRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/admin', adminRoutes);

// Test route
app.get('/', (req, res) => {
  res.json({ message: '✅ Household Services API is running!' });
});

// ========== SENTRY ERROR HANDLER ==========
// This must be BEFORE the 404 handler but AFTER all routes
Sentry.setupExpressErrorHandler(app);

// ========== 404 HANDLER ==========
// Catches all undefined routes
app.use((req, res) => {
  res.status(404).json({ message: '❌ Route not found' });
});

// ========== CUSTOM ERROR HANDLER ==========
// This catches all errors and sends a formatted response
// The error is already captured by Sentry from the handler above
app.use((err, req, res, next) => {
  console.error('Error caught:', err.message);
  res.status(500).json({ 
    message: 'Server error',
    errorId: res.sentry // Sentry event ID for debugging
  });
});

module.exports = app;