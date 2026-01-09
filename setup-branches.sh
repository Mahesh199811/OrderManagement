#!/bin/bash

# Git Branch Setup Script for Order Management System
# This script creates and configures all necessary branches for the environment strategy

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info "==================================="
print_info "Git Branch Setup Script"
print_info "==================================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_warning "Not a git repository. Initializing..."
    git init
    git add .
    git commit -m "Initial commit"
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
print_info "Current branch: $CURRENT_BRANCH"

# Create develop branch
if git show-ref --verify --quiet refs/heads/develop; then
    print_info "✓ develop branch already exists"
else
    print_info "Creating develop branch..."
    git checkout -b develop
    git push -u origin develop 2>/dev/null || print_warning "Could not push to remote (remote may not exist yet)"
fi

# Create qa branch from develop
git checkout develop
if git show-ref --verify --quiet refs/heads/qa; then
    print_info "✓ qa branch already exists"
else
    print_info "Creating qa branch from develop..."
    git checkout -b qa
    git push -u origin qa 2>/dev/null || print_warning "Could not push to remote"
fi

# Create staging branch from qa
git checkout qa
if git show-ref --verify --quiet refs/heads/staging; then
    print_info "✓ staging branch already exists"
else
    print_info "Creating staging branch from qa..."
    git checkout -b staging
    git push -u origin staging 2>/dev/null || print_warning "Could not push to remote"
fi

# Ensure main branch exists
git checkout staging
if git show-ref --verify --quiet refs/heads/main; then
    print_info "✓ main branch already exists"
else
    print_info "Creating main branch from staging..."
    git checkout -b main
    git push -u origin main 2>/dev/null || print_warning "Could not push to remote"
fi

# Return to develop branch
git checkout develop

print_info "==================================="
print_info "Branch setup completed!"
print_info "==================================="
print_info "Available branches:"
git branch
print_info ""
print_info "Current branch: develop (recommended for daily work)"
print_info ""
print_info "Branch strategy:"
print_info "  develop → qa → staging → main"
print_info ""
print_info "Next steps:"
print_info "1. Set 'develop' as default branch in your Git hosting service"
print_info "2. Add branch protection rules for main, staging, and qa"
print_info "3. Configure CI/CD pipelines for each branch"
