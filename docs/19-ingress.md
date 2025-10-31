# Module 19: Ingress

## Overview

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. It provides load balancing, SSL termination, and name-based virtual hosting.

## Learning Objectives

- Understand what Ingress is and why it's needed
- Install and configure an Ingress Controller
- Create Ingress resources for routing
- Configure path-based and host-based routing
- Set up TLS/SSL termination

## Why Ingress?

### Without Ingress

```
LoadBalancer per service = expensive!

Service 1 → LoadBalancer 1 ($$)
Service 2 → LoadBalancer 2 ($$)
Service 3 → LoadBalancer 3 ($$)
```

### With Ingress

```
One LoadBalancer → Ingress Controller → Route to services

           LoadBalancer ($)
                ↓
         Ingress Controller
           ↙    ↓    ↘
     Service1 Service2 Service3
```

## Ingress Components

1. **Ingress Controller**: Implementation (nginx, traefik, etc.)
2. **Ingress Resource**: Rules for routing traffic

## Installing Ingress Controller

### Nginx Ingress Controller

```bash
# Install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Check installation
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### For Minikube

```bash
minikube addons enable ingress
```

## Basic Ingress Example

```yaml
# Backend services first
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
---
# Ingress resource
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

## Path Types

- **Exact**: Exact match only
- **Prefix**: Matches prefix (most common)
- **ImplementationSpecific**: Depends on Ingress Controller

```yaml
paths:
- path: /api/v1
  pathType: Exact        # Only /api/v1
  
- path: /api
  pathType: Prefix       # /api, /api/users, /api/posts
  
- path: /special
  pathType: ImplementationSpecific  # Controller-specific
```

## Host-Based Routing

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-ingress
spec:
  ingressClassName: nginx
  rules:
  # example.com → web-service
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
  
  # api.example.com → api-service
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  
  # admin.example.com → admin-service
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
```

## TLS/HTTPS

### Create TLS Secret

```bash
# Generate self-signed certificate (for testing)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=example.com/O=example"

# Create secret
kubectl create secret tls example-tls \
  --cert=tls.crt \
  --key=tls.key
```

### Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - example.com
    - www.example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## Annotations

Ingress Controllers use annotations for configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: annotated-ingress
  annotations:
    # Nginx Ingress Controller annotations
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    
    # Authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    
    # CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## Rewrite Target Example

```yaml
# Request: example.com/api/users
# Rewritten to: backend-service/users

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```

## Complete Example

```yaml
# Deployments
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.21
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx:1.21
        ports:
        - containerPort: 80
---
# Services
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
  - port: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 80
---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 80
```

## Hands-On Labs

### Lab 1: Basic Ingress

```bash
# Create deployment and service
kubectl create deployment web --image=nginx --replicas=2
kubectl expose deployment web --port=80

# Create ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: web.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
EOF

# Get ingress address
kubectl get ingress web-ingress

# Test (add to /etc/hosts if needed)
# 192.168.49.2 web.local
curl http://web.local
```

### Lab 2: Path-Based Routing

```bash
# Create two services
kubectl create deployment app1 --image=nginx --replicas=2
kubectl expose deployment app1 --port=80

kubectl create deployment app2 --image=nginx --replicas=2
kubectl expose deployment app2 --port=80

# Create ingress with path routing
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: apps.local
    http:
      paths:
      - path: /app1
        pathType: Prefix
        backend:
          service:
            name: app1
            port:
              number: 80
      - path: /app2
        pathType: Prefix
        backend:
          service:
            name: app2
            port:
              number: 80
EOF

# Test
curl http://apps.local/app1
curl http://apps.local/app2
```

### Lab 3: TLS Ingress

```bash
# Generate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=secure.local/O=test"

# Create TLS secret
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key

# Create ingress with TLS
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - secure.local
    secretName: tls-secret
  rules:
  - host: secure.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
EOF

# Test
curl -k https://secure.local
```

## Common Ingress Controllers

| Controller | Provider | Features |
|------------|----------|----------|
| Nginx | Community/F5 | Most popular, feature-rich |
| Traefik | Traefik Labs | Auto-discovery, modern UI |
| HAProxy | HAProxy Tech | High performance |
| Kong | Kong Inc | API gateway features |
| AWS ALB | AWS | Native AWS integration |
| GCE | Google | Native GCP integration |

## Best Practices

1. **Use one Ingress Controller** - Avoid multiple controllers
2. **Set ingressClassName** - Explicitly specify class
3. **Use TLS** - Always use HTTPS in production
4. **Rate limiting** - Protect backends from abuse
5. **Monitor Ingress** - Watch for errors and latency
6. **Use annotations wisely** - Controller-specific features
7. **Default backend** - Handle 404s gracefully

## Troubleshooting

```bash
# Check Ingress Controller pods
kubectl get pods -n ingress-nginx

# Check Ingress resource
kubectl get ingress
kubectl describe ingress <name>

# Check Ingress Controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Test service directly
kubectl port-forward service/<service-name> 8080:80

# Check endpoints
kubectl get endpoints <service-name>
```

## Key Takeaways

- **Ingress = HTTP/HTTPS routing** - Layer 7 load balancing
- **Ingress Controller needed** - Implementation (nginx, traefik)
- **Path and host-based routing** - Route to different services
- **TLS termination** - Handle HTTPS at Ingress
- **Annotations configure behavior** - Controller-specific
- **One LoadBalancer for many services** - Cost-effective
- **IngressClass** - Multiple controllers support

## Next Steps

- **[Module 20: Network Policies](20-network-policies.md)**
- Practice with examples in `examples/ingress/`

## Additional Resources

- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
