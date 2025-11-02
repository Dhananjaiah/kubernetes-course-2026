#!/bin/bash

# E-Commerce Microservices Cleanup Script
# This script removes all deployed resources from Kubernetes

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

# Confirm cleanup
confirm_cleanup() {
    print_warning "This will delete all microservices resources from your cluster."
    read -p "Are you sure you want to continue? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        print_info "Cleanup cancelled."
        exit 0
    fi
}

# Delete resources
cleanup_resources() {
    print_header "Cleaning Up Resources"
    
    print_info "Deleting deployments..."
    kubectl delete -f k8s/deployments/ --ignore-not-found=true > /dev/null 2>&1
    print_success "Deployments deleted"
    
    print_info "Deleting databases..."
    kubectl delete -f k8s/databases/ --ignore-not-found=true > /dev/null 2>&1
    print_success "Databases deleted"
    
    print_info "Deleting secrets..."
    kubectl delete -f k8s/secrets/ --ignore-not-found=true > /dev/null 2>&1
    print_success "Secrets deleted"
    
    # Delete PVCs if they still exist
    if kubectl get pvc mongodb-pvc &> /dev/null; then
        print_info "Deleting MongoDB PVC..."
        kubectl delete pvc mongodb-pvc > /dev/null 2>&1
        print_success "MongoDB PVC deleted"
    fi
    
    if kubectl get pvc postgres-pvc &> /dev/null; then
        print_info "Deleting PostgreSQL PVC..."
        kubectl delete pvc postgres-pvc > /dev/null 2>&1
        print_success "PostgreSQL PVC deleted"
    fi
}

# Verify cleanup
verify_cleanup() {
    print_header "Verifying Cleanup"
    
    local pods=$(kubectl get pods 2>/dev/null | grep -E "(product-service|user-service|order-service|cart-service|frontend|mongodb|postgres|redis)" | wc -l)
    
    if [ "$pods" -eq 0 ]; then
        print_success "All resources cleaned up successfully!"
    else
        print_warning "Some pods may still be terminating. Check with: kubectl get pods"
    fi
}

# Main execution
main() {
    print_header "E-Commerce Microservices Cleanup"
    
    # Confirm
    confirm_cleanup
    
    # Cleanup
    cleanup_resources
    
    # Wait a moment for resources to be deleted
    sleep 2
    
    # Verify
    verify_cleanup
    
    print_header "Cleanup Complete!"
    
    echo ""
    print_info "To redeploy the application, run:"
    echo "  ./deploy.sh"
    echo ""
}

# Run main function
main
