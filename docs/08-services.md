# Module 8: Services

## Overview

Services provide stable networking for pods in Kubernetes. While pods are ephemeral and can be replaced at any time, Services provide a consistent way to access them through stable IP addresses and DNS names.

## Learning Objectives

By the end of this module, you will be able to:
- Understand what Services are and why they're needed
- Create and configure different Service types
- Use Services for pod-to-pod communication
- Expose applications externally using NodePort and LoadBalancer
- Understand Service discovery and DNS
- Troubleshoot Service networking issues

## Table of Contents

1. [Why Services?](#why-services)
2. [Service Types](#service-types)
3. [ClusterIP Services](#clusterip-services)
4. [NodePort Services](#nodeport-services)
5. [LoadBalancer Services](#loadbalancer-services)
6. [Service Discovery](#service-discovery)
7. [Endpoints](#endpoints)
8. [Hands-On Labs](#hands-on-labs)

---

## Why Services?

### The Problem: Pod IPs are Ephemeral

Pods are ephemeral - they can be created, destroyed, and recreated at any time:

```
Time 0: Frontend connects to Backend Pod
Frontend (10.1.1.5) → Backend Pod (10.1.2.3)

Time 1: Backend Pod crashes and is recreated
Backend Pod gets NEW IP: 10.1.2.8

Frontend still tries old IP (10.1.2.3) → ❌ Connection fails!
```

### The Solution: Services

A **Service** provides a stable virtual IP (VIP) and DNS name that doesn't change:

```
Frontend → Service (stable IP: 10.96.0.10, DNS: backend-service)
              ↓
Service routes to current Backend Pods
              ↓
    ┌─────────┴─────────┐
    ↓                   ↓
Backend Pod 1      Backend Pod 2
(10.1.2.3)         (10.1.2.8)

Even if pods change, Service IP remains the same!
```

### Key Benefits

1. **Stable Network Endpoint**: Service IP never changes
2. **Load Balancing**: Distributes traffic across multiple pods
3. **Service Discovery**: Find services by DNS name
4. **Decoupling**: Frontend doesn't need to know about backend pods
5. **Health Checking**: Only routes to healthy pods

---

## Service Types

Kubernetes provides four Service types:

| Type | Purpose | Access From | Use Case |
|------|---------|-------------|----------|
| **ClusterIP** | Internal only | Within cluster | Internal microservices |
| **NodePort** | External via node | Outside cluster | Development, testing |
| **LoadBalancer** | External via LB | Outside cluster | Production external access |
| **ExternalName** | DNS CNAME | Within cluster | External service proxy |

### Service Type Decision Tree

```
Do you need external access?
│
├─ No → Use ClusterIP
│        (Default, internal only)
│
└─ Yes → Is this production?
         │
         ├─ Yes → Use LoadBalancer
         │         (Cloud load balancer)
         │
         └─ No → Use NodePort
                   (Direct node access)
```

---

## ClusterIP Services

### What is ClusterIP?

**ClusterIP** is the default Service type. It creates an internal virtual IP accessible only within the cluster.

### Use Cases

- Microservice-to-microservice communication
- Database accessed by application pods
- Internal APIs
- Any service that doesn't need external access

### ClusterIP Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP  # Default, can be omitted
  
  # Select pods with these labels
  selector:
    app: backend
    
  ports:
  - name: http
    port: 80           # Service port
    targetPort: 8080   # Container port
    protocol: TCP
```

**How it works:**

```
1. Service gets virtual IP: 10.96.0.10
2. Service selects pods with label app=backend
3. Requests to 10.96.0.10:80 → routed to pods on port 8080
4. Load-balanced across all matching pods
```

### Creating ClusterIP Service

```bash
# Imperative
kubectl create service clusterip backend-service --tcp=80:8080

# Or using kubectl expose
kubectl create deployment backend --image=nginx --replicas=3
kubectl expose deployment backend --port=80 --target-port=8080 --name=backend-service
```

### Accessing ClusterIP Service

```bash
# From another pod
curl http://backend-service:80
curl http://backend-service.default.svc.cluster.local:80

# From kubectl exec
kubectl run test-pod --image=busybox -it --rm -- sh
/ # wget -O- http://backend-service
```

---

## NodePort Services

### What is NodePort?

**NodePort** exposes the Service on each Node's IP at a static port. You can access the Service from outside the cluster using `<NodeIP>:<NodePort>`.

### How NodePort Works

```
External Client
     │
     ↓
Node IP:30080 ─────┐
Node IP:30080 ──┬──┤
Node IP:30080 ──┘  │
                   ↓
            Service (10.96.0.10:80)
                   │
        ┌──────────┼──────────┐
        ↓          ↓          ↓
      Pod 1      Pod 2      Pod 3
```

### NodePort Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-nodeport
spec:
  type: NodePort
  
  selector:
    app: frontend
    
  ports:
  - name: http
    port: 80           # Service port
    targetPort: 8080   # Container port
    nodePort: 30080    # Node port (30000-32767)
```

### Port Mappings

NodePort Services have three port types:

- **nodePort**: External port on each node (30000-32767 range)
- **port**: Service's internal port
- **targetPort**: Container's port

```
Request Flow:
<Node-IP>:30080 → Service:80 → Pod:8080
```

### Creating NodePort Service

```bash
# Imperative
kubectl create deployment web --image=nginx
kubectl expose deployment web --type=NodePort --port=80 --target-port=80

# Get the assigned NodePort
kubectl get service web
```

### Accessing NodePort Service

```bash
# Get Node IP
kubectl get nodes -o wide

# Access service
curl http://<node-ip>:30080

# Or get NodePort
NODE_PORT=$(kubectl get service frontend-nodeport -o jsonpath='{.spec.ports[0].nodePort}')
curl http://<node-ip>:$NODE_PORT
```

---

## LoadBalancer Services

### What is LoadBalancer?

**LoadBalancer** provisions an external load balancer (in cloud providers like AWS, GCP, Azure) that routes traffic to the Service.

### How LoadBalancer Works

```
Internet
    │
    ↓
Cloud Load Balancer (External IP: 203.0.113.1)
    │
    ↓
Service (10.96.0.10)
    │
    ┌──────────┼──────────┐
    ↓          ↓          ↓
  Node 1     Node 2     Node 3
    ↓          ↓          ↓
  Pod 1      Pod 2      Pod 3
```

### LoadBalancer Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-loadbalancer
spec:
  type: LoadBalancer
  
  selector:
    app: web
    
  ports:
  - name: http
    port: 80
    targetPort: 8080
    protocol: TCP
    
  # Optional: Set source IP ranges
  loadBalancerSourceRanges:
  - 203.0.113.0/24
```

### Creating LoadBalancer Service

```bash
# Create deployment
kubectl create deployment web --image=nginx --replicas=3

# Expose as LoadBalancer
kubectl expose deployment web --type=LoadBalancer --port=80 --target-port=80 --name=web-lb

# Wait for external IP to be assigned
kubectl get service web-lb --watch
```

### Accessing LoadBalancer Service

```bash
# Get external IP
EXTERNAL_IP=$(kubectl get service web-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Access service
curl http://$EXTERNAL_IP
```

### LoadBalancer Notes

- **Cloud Provider Required**: Works with AWS, GCP, Azure, etc.
- **Cost**: Each LoadBalancer service provisions a cloud load balancer ($$)
- **Minikube**: Uses `minikube tunnel` to simulate LoadBalancer
- **Alternative**: Use Ingress (Module 19) for multiple services behind one LB

---

## Service Discovery

### DNS-Based Discovery

Kubernetes automatically creates DNS records for Services:

**Format:**
```
<service-name>.<namespace>.svc.cluster.local
```

**Examples:**
```
backend-service.default.svc.cluster.local
database.production.svc.cluster.local
api.staging.svc.cluster.local
```

### Within Same Namespace

Pods can use short names:

```bash
# Full DNS name
curl http://backend-service.default.svc.cluster.local

# Short name (same namespace)
curl http://backend-service

# Even shorter (assumes :80 if not specified)
curl backend-service
```

### Cross-Namespace Access

```bash
# From default namespace to production namespace
curl http://database.production.svc.cluster.local

# Or shorter
curl http://database.production
```

### Environment Variables

Kubernetes also creates environment variables for Services:

```bash
# For service named "backend-service"
BACKEND_SERVICE_SERVICE_HOST=10.96.0.10
BACKEND_SERVICE_SERVICE_PORT=80
BACKEND_SERVICE_PORT=tcp://10.96.0.10:80
BACKEND_SERVICE_PORT_80_TCP=tcp://10.96.0.10:80
BACKEND_SERVICE_PORT_80_TCP_PROTO=tcp
BACKEND_SERVICE_PORT_80_TCP_PORT=80
BACKEND_SERVICE_PORT_80_TCP_ADDR=10.96.0.10
```

**Note:** Environment variables are only set for Services that exist when the pod starts. DNS is more flexible and recommended.

---

## Endpoints

### What are Endpoints?

**Endpoints** are the actual IP addresses and ports of pods that a Service routes to.

### Viewing Endpoints

```bash
# Create service
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --port=80

# View endpoints
kubectl get endpoints nginx

# Output:
# NAME    ENDPOINTS                           AGE
# nginx   10.1.2.3:80,10.1.2.4:80,10.1.2.5:80  1m

# Detailed view
kubectl describe endpoints nginx
```

### How Endpoints Work

```
Service Creation:
1. Service created with selector: app=nginx
2. Kubernetes finds all pods with label app=nginx
3. Creates Endpoint object with pod IPs
4. Service routes traffic to these IPs
5. Endpoints automatically updated when pods change
```

### Headless Services

A headless Service (ClusterIP: None) doesn't load balance - it returns all pod IPs:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-service
spec:
  clusterIP: None  # Makes it headless
  selector:
    app: database
  ports:
  - port: 3306
```

**Use cases:**
- StatefulSets (Module 17)
- Direct pod-to-pod communication
- Custom load balancing logic

---

## Hands-On Labs

### Lab 1: ClusterIP Service

**Objective:** Create an internal service for pod-to-pod communication

**Steps:**

1. Create a backend deployment:
```bash
kubectl create deployment backend --image=nginx --replicas=3
```

2. Create ClusterIP service:
```bash
kubectl expose deployment backend --port=80 --target-port=80 --name=backend-service
```

3. Verify service:
```bash
kubectl get service backend-service
kubectl describe service backend-service
```

4. Check endpoints:
```bash
kubectl get endpoints backend-service
```

5. Test access from another pod:
```bash
kubectl run test-pod --image=busybox -it --rm -- sh
/ # wget -O- http://backend-service
/ # wget -O- http://backend-service.default.svc.cluster.local
```

6. Scale backend and observe endpoints:
```bash
kubectl scale deployment backend --replicas=5
kubectl get endpoints backend-service --watch
```

### Lab 2: NodePort Service

**Objective:** Expose a service externally using NodePort

**Steps:**

1. Create deployment:
```bash
kubectl create deployment web --image=nginx --replicas=3
```

2. Create NodePort service:
```yaml
# web-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-nodeport
spec:
  type: NodePort
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

3. Apply:
```bash
kubectl apply -f web-nodeport.yaml
```

4. Get Node IP:
```bash
kubectl get nodes -o wide
# Note the INTERNAL-IP or EXTERNAL-IP
```

5. Access service:
```bash
# If using Minikube
minikube service web-nodeport --url

# Or directly
curl http://<node-ip>:30080
```

6. Verify load balancing:
```bash
# Make multiple requests
for i in {1..10}; do curl -s http://<node-ip>:30080 | grep hostname; done
```

### Lab 3: LoadBalancer Service (Cloud/Minikube)

**Objective:** Create a LoadBalancer service

**Steps:**

1. Create deployment:
```bash
kubectl create deployment lb-app --image=nginx --replicas=3
```

2. Expose as LoadBalancer:
```bash
kubectl expose deployment lb-app --type=LoadBalancer --port=80 --target-port=80 --name=lb-service
```

3. For Minikube users - start tunnel:
```bash
# In separate terminal
minikube tunnel
```

4. Wait for external IP:
```bash
kubectl get service lb-service --watch
```

5. Access service:
```bash
EXTERNAL_IP=$(kubectl get service lb-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP
```

### Lab 4: Service Discovery with DNS

**Objective:** Understand DNS-based service discovery

**Steps:**

1. Create multiple services:
```bash
kubectl create deployment app1 --image=nginx
kubectl expose deployment app1 --port=80
kubectl create deployment app2 --image=nginx
kubectl expose deployment app2 --port=80
```

2. Create test pod:
```bash
kubectl run dns-test --image=busybox -it --rm -- sh
```

3. Test DNS resolution:
```bash
# Short name
/ # nslookup app1

# Full name
/ # nslookup app1.default.svc.cluster.local

# Access service
/ # wget -O- http://app1
/ # wget -O- http://app2
```

4. Check environment variables:
```bash
/ # env | grep APP1_SERVICE
```

### Lab 5: Service Selectors and Labels

**Objective:** Understand how selectors work

**Steps:**

1. Create pods with different labels:
```bash
kubectl run pod-v1-1 --image=nginx --labels="app=myapp,version=v1"
kubectl run pod-v1-2 --image=nginx --labels="app=myapp,version=v1"
kubectl run pod-v2-1 --image=nginx --labels="app=myapp,version=v2"
```

2. Create service for v1 pods:
```yaml
# service-v1.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-v1
spec:
  selector:
    app: myapp
    version: v1
  ports:
  - port: 80
```

3. Apply and check endpoints:
```bash
kubectl apply -f service-v1.yaml
kubectl get endpoints myapp-v1
# Should show only v1 pods
```

4. Change a pod's label:
```bash
kubectl label pod pod-v1-1 version=v2 --overwrite
```

5. Check endpoints again:
```bash
kubectl get endpoints myapp-v1
# Should now show only pod-v1-2
```

### Lab 6: Cleanup

```bash
kubectl delete deployments --all
kubectl delete services --all
kubectl delete pods --all
```

---

## Common Commands Reference

### Create Services

```bash
# ClusterIP (default)
kubectl expose deployment <name> --port=80 --target-port=8080

# NodePort
kubectl expose deployment <name> --type=NodePort --port=80

# LoadBalancer
kubectl expose deployment <name> --type=LoadBalancer --port=80

# From YAML
kubectl apply -f service.yaml
```

### View Services

```bash
# List services
kubectl get services
kubectl get svc

# Detailed info
kubectl describe service <name>

# View endpoints
kubectl get endpoints <name>

# View service as YAML
kubectl get service <name> -o yaml
```

### Access Services

```bash
# Get ClusterIP
kubectl get service <name> -o jsonpath='{.spec.clusterIP}'

# Get NodePort
kubectl get service <name> -o jsonpath='{.spec.ports[0].nodePort}'

# Get LoadBalancer IP
kubectl get service <name> -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Port forward for testing
kubectl port-forward service/<name> 8080:80
```

### Troubleshooting

```bash
# Check if service has endpoints
kubectl get endpoints <service-name>

# Check if pods match selector
kubectl get pods -l <selector>

# Test connectivity
kubectl run test --image=busybox -it --rm -- wget -O- <service-name>

# Check DNS
kubectl run test --image=busybox -it --rm -- nslookup <service-name>
```

### Delete Services

```bash
kubectl delete service <name>
kubectl delete service -l app=myapp
```

---

## Troubleshooting Common Issues

### Issue 1: Service Has No Endpoints

**Symptoms:**
```bash
kubectl get endpoints myservice
# NAME        ENDPOINTS   AGE
# myservice   <none>      2m
```

**Possible Causes:**
1. No pods match the selector
2. Pods not ready
3. Port mismatch

**Solutions:**
```bash
# Check if pods exist with correct labels
kubectl get pods -l <selector>

# Check service selector
kubectl describe service myservice | grep Selector

# Check pod labels
kubectl get pods --show-labels

# Ensure labels match
kubectl describe service myservice
```

### Issue 2: Cannot Access Service

**Symptoms:**
- Connection timeout
- Connection refused

**Solutions:**
```bash
# 1. Verify service exists
kubectl get service <name>

# 2. Check endpoints
kubectl get endpoints <name>

# 3. Test from within cluster
kubectl run test --image=busybox -it --rm -- wget -O- <service-name>

# 4. Check pod logs
kubectl logs <pod-name>

# 5. Verify port numbers
kubectl describe service <name>
```

### Issue 3: LoadBalancer Pending

**Symptoms:**
```bash
kubectl get service
# NAME   TYPE           EXTERNAL-IP   PORT(S)
# web    LoadBalancer   <pending>     80:30123/TCP
```

**Possible Causes:**
1. Not running on cloud provider
2. Cloud provider integration not configured
3. Using Minikube without tunnel

**Solutions:**
```bash
# For Minikube
minikube tunnel

# For cloud - check cloud provider setup
kubectl describe service <name> | grep Events

# Alternative - use NodePort or Ingress
kubectl patch service <name> -p '{"spec":{"type":"NodePort"}}'
```

### Issue 4: DNS Not Working

**Symptoms:**
- Cannot resolve service name

**Solutions:**
```bash
# Check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test DNS from pod
kubectl run test --image=busybox -it --rm -- nslookup kubernetes.default

# Check service exists
kubectl get service <name>
```

---

## Best Practices

### 1. Use Meaningful Service Names

```yaml
# ✅ Good
name: user-api-service
name: payment-processor
name: database-primary

# ❌ Bad
name: service1
name: svc
name: test
```

### 2. Always Define targetPort

```yaml
# ✅ Good - Explicit
ports:
- port: 80
  targetPort: 8080

# ❌ Unclear - Implicit
ports:
- port: 80
  # targetPort defaults to port (80)
```

### 3. Use Named Ports

```yaml
# ✅ Good
ports:
- name: http
  port: 80
  targetPort: 8080
- name: metrics
  port: 9090
  targetPort: 9090
```

### 4. Label Services

```yaml
# ✅ Good
metadata:
  name: user-api
  labels:
    app: user-api
    tier: backend
    environment: production
```

### 5. Use ClusterIP for Internal Services

```yaml
# ✅ Good for internal services
type: ClusterIP

# ❌ Avoid exposing internal services
type: LoadBalancer  # Only for external access
```

### 6. Consider Service Mesh for Complex Scenarios

For advanced scenarios, consider service meshes like Istio or Linkerd:
- Advanced traffic routing
- Mutual TLS
- Circuit breaking
- Observability

---

## Key Takeaways

1. **Services provide stable endpoints** - Pod IPs change, Service IPs don't
2. **ClusterIP for internal** - Default type, cluster-internal only
3. **NodePort for external (dev/test)** - Access via node IP and static port
4. **LoadBalancer for production external** - Cloud provider load balancer
5. **DNS-based discovery** - Use service names, not IPs
6. **Selectors match labels** - Services route to pods with matching labels
7. **Endpoints show target pods** - Check endpoints to verify service connectivity

---

## Next Steps

Now that you understand Services, you're ready for:
- **[Module 9: Update Strategies & Rollback](09-update-strategies.md)** - Safely update services
- **[Module 19: Ingress](19-ingress.md)** - Advanced external access (later)
- Practice with the example YAML files in `examples/services/`

---

## Additional Resources

- [Kubernetes Official Docs - Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Service Types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)
- [DNS for Services](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [kubectl Cheat Sheet](kubectl-cheatsheet.md)

---

**Congratulations!** You now understand how to expose and access applications in Kubernetes! 🎉
