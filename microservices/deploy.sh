#!/bin/bash

# E-Commerce Microservices Deployment Script
# This script automates the deployment of the microservices application to Kubernetes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if kubectl is installed
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl not found. Please install kubectl first."
        exit 1
    fi
    print_success "kubectl is installed"
}

# Check if Kubernetes cluster is accessible
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please start your cluster first."
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
}

# Build Docker images
build_images() {
    print_header "Building Docker Images"
    
    local services=("product-service" "user-service" "order-service" "cart-service" "frontend")
    
    for service in "${services[@]}"; do
        print_info "Building $service..."
        docker build -t "${service}:latest" "./${service}" > /dev/null 2>&1
        print_success "Built ${service}:latest"
    done
}

# Load images into Minikube (if using Minikube)
load_images_minikube() {
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        print_header "Loading Images into Minikube"
        eval $(minikube docker-env)
        build_images
        print_success "Images loaded into Minikube"
        return 0
    fi
    return 1
}

# Load images into kind (if using kind)
load_images_kind() {
    if command -v kind &> /dev/null; then
        print_header "Loading Images into kind"
        local services=("product-service" "user-service" "order-service" "cart-service" "frontend")
        
        for service in "${services[@]}"; do
            kind load docker-image "${service}:latest" > /dev/null 2>&1
            print_success "Loaded ${service}:latest into kind"
        done
        return 0
    fi
    return 1
}

# Deploy to Kubernetes
deploy_k8s() {
    print_header "Deploying to Kubernetes"
    
    print_info "Creating secrets..."
    kubectl apply -f k8s/secrets/ > /dev/null 2>&1
    print_success "Secrets created"
    
    print_info "Deploying databases..."
    kubectl apply -f k8s/databases/ > /dev/null 2>&1
    print_success "Databases deployed"
    
    print_info "Deploying microservices..."
    kubectl apply -f k8s/deployments/ > /dev/null 2>&1
    print_success "Microservices deployed"
}

# Wait for pods to be ready
wait_for_pods() {
    print_header "Waiting for Pods to be Ready"
    
    print_info "This may take a few minutes..."
    
    kubectl wait --for=condition=ready pod -l tier=database --timeout=300s > /dev/null 2>&1
    print_success "Database pods are ready"
    
    kubectl wait --for=condition=ready pod -l tier=backend --timeout=300s > /dev/null 2>&1
    print_success "Backend service pods are ready"
    
    kubectl wait --for=condition=ready pod -l tier=frontend --timeout=300s > /dev/null 2>&1
    print_success "Frontend pod is ready"
}

# Show deployment status
show_status() {
    print_header "Deployment Status"
    
    echo ""
    print_info "Pods:"
    kubectl get pods
    
    echo ""
    print_info "Services:"
    kubectl get services
    
    echo ""
    print_info "Deployments:"
    kubectl get deployments
}

# Get access URL
get_access_url() {
    print_header "Access Information"
    
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        print_success "Run the following command to access the application:"
        echo "minikube service frontend"
    elif kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' &> /dev/null; then
        EXTERNAL_IP=$(kubectl get service frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        print_success "Access the application at: http://${EXTERNAL_IP}"
    else
        print_warning "Service is not exposed externally. Use port-forward:"
        echo "kubectl port-forward service/frontend 3000:80"
        echo "Then visit: http://localhost:3000"
    fi
}

# Main execution
main() {
    print_header "E-Commerce Microservices Deployment"
    
    # Checks
    check_kubectl
    check_cluster
    
    # Build and load images
    if ! load_images_minikube; then
        if ! load_images_kind; then
            print_warning "Not using Minikube or kind. Make sure images are available in your registry."
            build_images
        fi
    fi
    
    # Deploy
    deploy_k8s
    
    # Wait for deployment
    wait_for_pods
    
    # Show status
    show_status
    
    # Get access URL
    get_access_url
    
    print_header "Deployment Complete!"
    print_success "All services are up and running!"
    
    echo ""
    print_info "Useful commands:"
    echo "  kubectl get pods              # Check pod status"
    echo "  kubectl logs -f <pod-name>    # View logs"
    echo "  kubectl describe pod <name>   # Debug pod issues"
    echo "  kubectl get services          # List services"
    echo ""
}

# Run main function
main
