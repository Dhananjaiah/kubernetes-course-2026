# Security Considerations

This document outlines security considerations and known limitations of the microservices application.

## ⚠️ Important: Educational Purpose

**This application is designed for learning and demonstration purposes.** While it follows many best practices, it should NOT be deployed to production without additional security hardening.

## Current Security Features

### ✅ Implemented

1. **Password Hashing**
   - User passwords are hashed using bcrypt
   - Passwords never stored in plain text

2. **JWT Authentication**
   - Token-based authentication for protected endpoints
   - Tokens expire after 24 hours

3. **Kubernetes Secrets**
   - Database passwords stored in Kubernetes secrets
   - JWT secret key stored separately

4. **Non-root Containers**
   - All containers run as non-root user (nodejs, uid: 1001)
   - Reduces attack surface

5. **Resource Limits**
   - CPU and memory limits on all pods
   - Prevents resource exhaustion

6. **Health Checks**
   - Liveness and readiness probes
   - Automatic restart of unhealthy pods

7. **CORS Configuration**
   - CORS enabled for cross-origin requests
   - Can be restricted to specific origins

8. **Dependency Security**
   - All dependencies updated to patch known vulnerabilities
   - Mongoose 7.8.4 (patched search injection)
   - Axios 1.12.0 (patched DoS and SSRF)

## ⚠️ Known Limitations (Educational Project)

### 1. Missing Rate Limiting

**Issue**: All API endpoints lack rate limiting

**Risk**: 
- Vulnerable to brute force attacks
- Can be overwhelmed by excessive requests
- DoS attacks possible

**For Production**: Add rate limiting middleware
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

### 2. Race Conditions in Order Processing

**Issue**: Stock updates in order processing can have race conditions

**Risk**:
- Concurrent orders may oversell products
- Two orders for the last item may both succeed

**For Production**: Implement distributed transaction patterns:
- Saga pattern
- Two-Phase Commit (2PC)
- Optimistic locking with version numbers

### 3. Request Forgery Warnings

**Issue**: CodeQL flags user-provided values in request URLs

**Risk**: 
- These are expected REST API patterns (e.g., `/api/products/:id`)
- Low risk for internal microservice communication

**For Production**: 
- Validate and sanitize all ID parameters
- Use UUID instead of sequential IDs
- Implement request signing for service-to-service communication

### 4. SQL Injection Warnings

**Issue**: CodeQL flags query objects with user input

**Note**: These are false positives
- MongoDB uses parameterized queries (safe)
- PostgreSQL uses prepared statements (safe)

**Current Protection**:
```javascript
// Safe - uses parameterized query
await Product.find(query); // MongoDB
await pool.query('SELECT * FROM users WHERE id = $1', [id]); // PostgreSQL
```

### 5. JWT Secret Management

**Issue**: JWT secret stored in Kubernetes secret (plain text)

**Risk**:
- Anyone with access to the secret can decode JWTs
- Secret rotation requires service restart

**For Production**:
- Use external secret management (HashiCorp Vault, AWS Secrets Manager)
- Implement key rotation
- Use asymmetric keys (RS256 instead of HS256)

### 6. Database Security

**Issue**: Simple password-based authentication

**For Production**:
- Use certificate-based authentication
- Enable TLS/SSL for database connections
- Implement database encryption at rest
- Use separate database users with minimal privileges

### 7. No Input Validation

**Issue**: Limited input validation and sanitization

**For Production**: Add comprehensive validation
```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/users/register',
  body('email').isEmail(),
  body('password').isLength({ min: 8 }),
  (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    // Process request
  }
);
```

### 8. No HTTPS

**Issue**: Services communicate over HTTP

**For Production**:
- Use TLS for all service-to-service communication
- Implement service mesh (Istio, Linkerd) for mTLS
- Use cert-manager for certificate management

### 9. Logging Sensitive Data

**Issue**: Error messages may expose sensitive information

**For Production**:
- Implement structured logging
- Sanitize error messages
- Don't log passwords, tokens, or PII
- Use log aggregation (ELK, Splunk)

### 10. No API Versioning

**Issue**: API endpoints lack version numbers

**For Production**: Implement versioning
```javascript
app.use('/api/v1/products', productRouter);
app.use('/api/v2/products', productRouterV2);
```

## Production Security Checklist

Before deploying to production, implement:

- [ ] Rate limiting on all endpoints
- [ ] Input validation and sanitization
- [ ] API versioning
- [ ] HTTPS/TLS everywhere
- [ ] Service mesh with mTLS
- [ ] Secret rotation mechanisms
- [ ] Comprehensive logging and monitoring
- [ ] Security scanning in CI/CD
- [ ] Network policies in Kubernetes
- [ ] Pod security policies
- [ ] RBAC for Kubernetes access
- [ ] Regular dependency updates
- [ ] Penetration testing
- [ ] Security audit
- [ ] Incident response plan

## Security Testing

### Manual Testing

Test authentication:
```bash
# Try accessing protected endpoint without token
curl http://localhost:3002/api/users/profile
# Should return 401

# Register and login
TOKEN=$(curl -X POST http://localhost:3002/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  | jq -r '.data.token')

# Access with token
curl http://localhost:3002/api/users/profile \
  -H "Authorization: Bearer $TOKEN"
```

### Automated Testing

Run security scanners:
```bash
# Dependency check
npm audit

# Container security scan
docker scan product-service:latest

# Kubernetes security scan
kube-bench run --targets master,node
```

## Reporting Security Issues

If you find security vulnerabilities in this educational project:

1. Open a GitHub issue with the "security" label
2. Describe the vulnerability
3. Suggest remediation if possible

**Note**: Since this is an educational project, we document issues rather than requiring immediate fixes.

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)

---

**Remember**: This is a learning project. Use it to understand microservices patterns, but add proper security before production use!
