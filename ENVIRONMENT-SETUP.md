# Environment Configuration & Deployment Guide

## 📋 Overview

This document outlines the environment management strategy for the Order Management System API. We use a multi-branch Git workflow with environment-specific configurations for DEV, QA, Staging, and Production environments.

---

## 🌳 Git Branching Strategy

### Branch Structure

```
main (Production)
├── staging
│   └── qa
│       └── develop
└── hotfix-* (emergency fixes)
```

### Branch Descriptions

| Branch | Environment | Purpose | Protection |
|--------|------------|---------|----------|
| `main` | Production | Production-ready code | Protected, requires PR approval |
| `staging` | Staging | Pre-production testing | Protected, requires PR approval |
| `qa` | QA | Quality assurance testing | Protected |
| `develop` | Development | Active development | Default branch |

---

## 🚀 Setting Up Git Branches

### Initial Setup (Run Once)

```bash
# Navigate to your project directory
cd /Users/maheshgadhave/Documents/OrderManagementSystem

# Create and push develop branch
git checkout -b develop
git push -u origin develop

# Create and push qa branch
git checkout -b qa
git push -u origin qa

# Create and push staging branch
git checkout -b staging
git push -u origin staging

# Ensure main branch exists
git checkout main
git push -u origin main

# Set develop as default working branch
git checkout develop
```

### Setting Default Branch in GitHub/GitLab

**GitHub:**
```
Settings → Branches → Default branch → develop → Update
```

**GitLab:**
```
Settings → Repository → Default Branch → develop → Save changes
```

---

## 🔄 Development Workflow

### Feature Development

```bash
# Start from develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes, commit, and push
git add .
git commit -m "feat: description of feature"
git push origin feature/your-feature-name

# Create Pull Request to develop branch
```

### Promoting to QA

```bash
# Merge develop to qa
git checkout qa
git pull origin qa
git merge develop
git push origin qa

# This triggers QA deployment
```

### Promoting to Staging

```bash
# Merge qa to staging
git checkout staging
git pull origin staging
git merge qa
git push origin staging

# This triggers Staging deployment
```

### Promoting to Production

```bash
# Merge staging to main (via Pull Request recommended)
git checkout main
git pull origin main
git merge staging
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main --tags

# This triggers Production deployment
```

### Hotfix Process

```bash
# Create hotfix from main
git checkout main
git checkout -b hotfix/critical-bug-fix

# Make fixes and test
git add .
git commit -m "hotfix: description"

# Merge to main
git checkout main
git merge hotfix/critical-bug-fix
git tag -a v1.0.1 -m "Hotfix version 1.0.1"
git push origin main --tags

# Backport to other branches
git checkout staging && git merge main && git push
git checkout qa && git merge staging && git push
git checkout develop && git merge qa && git push

# Delete hotfix branch
git branch -d hotfix/critical-bug-fix
git push origin --delete hotfix/critical-bug-fix
```

---

## 🔧 Environment Configurations

### Development (Local)

**Configuration File:** `appsettings.Development.json`

**Database:** Local PostgreSQL (localhost:5432)

**Run Commands:**
```bash
cd OrderManagement.API

# Using .NET CLI
dotnet run --environment Development

# Using Docker Compose
docker-compose -f docker-compose.dev.yml up --build
```

**Access:**
- API: http://localhost:8081
- Swagger: http://localhost:8081/swagger

---

### QA Environment

**Configuration File:** `appsettings.QA.json`

**Database:** QA PostgreSQL instance

**Environment Variables:**
```bash
export DB_PASSWORD="your-qa-db-password"
```

**Run Commands:**
```bash
cd OrderManagement.API

# Build and run with Docker
docker-compose -f docker-compose.qa.yml up --build -d

# View logs
docker-compose -f docker-compose.qa.yml logs -f api
```

**Access:**
- API: http://localhost:8082
- Swagger: http://localhost:8082/swagger

---

### Staging Environment

**Configuration File:** `appsettings.Staging.json`

**Database:** Staging PostgreSQL instance

**Environment Variables:**
```bash
export DB_PASSWORD="your-staging-db-password"
```

**Run Commands:**
```bash
cd OrderManagement.API

# Build and run with Docker
docker-compose -f docker-compose.staging.yml up --build -d

# View logs
docker-compose -f docker-compose.staging.yml logs -f api
```

**Access:**
- API: http://localhost:8083
- Swagger: http://localhost:8083/swagger

---

### Production Environment

**Configuration File:** `appsettings.Production.json`

**Database:** Production PostgreSQL (RDS/managed instance recommended)

**Environment Variables:**
```bash
export DB_HOST="production-db-host.rds.amazonaws.com"
export DB_NAME="OrderManagementDb_Prod"
export DB_USER="prod_user"
export DB_PASSWORD="your-secure-production-password"
```

**Run Commands:**
```bash
cd OrderManagement.API

# Build and run with Docker
docker-compose -f docker-compose.prod.yml up --build -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f api

# Monitor health
docker ps
docker stats
```

**Access:**
- API: http://localhost:8080
- Swagger: DISABLED in production (set EnableSwagger: false)

---

## 📊 Environment Variables Reference

### Development
```bash
ASPNETCORE_ENVIRONMENT=Development
ConnectionStrings__DefaultConnection="Host=localhost;Port=5432;Database=OrderManagementDb;Username=postgres;Password=postgres"
```

### QA
```bash
ASPNETCORE_ENVIRONMENT=QA
ConnectionStrings__DefaultConnection="Host=qa-postgres-db;Port=5432;Database=OrderManagementDb_QA;Username=postgres;Password=${DB_PASSWORD}"
DB_PASSWORD="your-qa-password"
```

### Staging
```bash
ASPNETCORE_ENVIRONMENT=Staging
ConnectionStrings__DefaultConnection="Host=staging-postgres-db;Port=5432;Database=OrderManagementDb_Staging;Username=postgres;Password=${DB_PASSWORD}"
DB_PASSWORD="your-staging-password"
```

### Production
```bash
ASPNETCORE_ENVIRONMENT=Production
ConnectionStrings__DefaultConnection="Host=${DB_HOST};Port=5432;Database=${DB_NAME};Username=${DB_USER};Password=${DB_PASSWORD}"
DB_HOST="your-production-db-host"
DB_NAME="OrderManagementDb_Prod"
DB_USER="prod_user"
DB_PASSWORD="your-production-password"
```

---

## 🔒 Security Best Practices

### 1. Environment Variables
- **Never commit** sensitive data (passwords, API keys) to Git
- Use `.env` files locally (add to `.gitignore`)
- Use secrets management in production (AWS Secrets Manager, Azure Key Vault, etc.)

### 2. Create .env Files

```bash
# .env.dev (for local development)
cat > OrderManagement.API/.env.dev << EOF
DB_PASSWORD=postgres
ASPNETCORE_ENVIRONMENT=Development
EOF

# .env.qa
cat > OrderManagement.API/.env.qa << EOF
DB_PASSWORD=your-qa-password
ASPNETCORE_ENVIRONMENT=QA
EOF

# .env.staging
cat > OrderManagement.API/.env.staging << EOF
DB_PASSWORD=your-staging-password
ASPNETCORE_ENVIRONMENT=Staging
EOF

# .env.prod
cat > OrderManagement.API/.env.prod << EOF
DB_HOST=your-production-db-host
DB_NAME=OrderManagementDb_Prod
DB_USER=prod_user
DB_PASSWORD=your-production-password
ASPNETCORE_ENVIRONMENT=Production
EOF
```

### 3. Update .gitignore

```bash
cat >> .gitignore << EOF

# Environment files
*.env
.env.*
!.env.example

# Local development
appsettings.*.local.json
EOF
```

---

## 🧪 Testing Deployments

### Development
```bash
curl http://localhost:8081/swagger
curl http://localhost:8081/api/orders
```

### QA
```bash
curl http://localhost:8082/swagger
curl http://localhost:8082/api/orders
```

### Staging
```bash
curl http://localhost:8083/swagger
curl http://localhost:8083/api/orders
```

### Production
```bash
curl http://localhost:8080/api/orders
# Note: Swagger disabled in production
```

---

## 🔄 Database Migrations

### Run Migrations per Environment

```bash
# Development
dotnet ef database update --environment Development

# QA
dotnet ef database update --environment QA

# Staging
dotnet ef database update --environment Staging

# Production
dotnet ef database update --environment Production
```

### Create New Migration

```bash
cd OrderManagement.API
dotnet ef migrations add YourMigrationName
```

---

## 📝 CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/deploy-dev.yml
name: Deploy to Development
on:
  push:
    branches: [develop]

# .github/workflows/deploy-qa.yml
name: Deploy to QA
on:
  push:
    branches: [qa]

# .github/workflows/deploy-staging.yml
name: Deploy to Staging
on:
  push:
    branches: [staging]

# .github/workflows/deploy-prod.yml
name: Deploy to Production
on:
  push:
    branches: [main]
```

---

## 🛠️ Useful Commands

### Docker Management

```bash
# Stop all containers
docker-compose -f docker-compose.{env}.yml down

# Remove volumes (clean database)
docker-compose -f docker-compose.{env}.yml down -v

# View container logs
docker logs -f {container-name}

# Rebuild without cache
docker-compose -f docker-compose.{env}.yml build --no-cache

# Check running containers
docker ps

# Clean up unused resources
docker system prune -a
```

### Git Management

```bash
# View all branches
git branch -a

# View current branch
git branch --show-current

# Delete local branch
git branch -d branch-name

# Delete remote branch
git push origin --delete branch-name

# View commit history
git log --oneline --graph --all

# View uncommitted changes
git status
git diff
```

---

## 📋 Checklist for New Environment Setup

- [ ] Create environment-specific appsettings file
- [ ] Configure database connection string
- [ ] Set up environment variables
- [ ] Create .env file (add to .gitignore)
- [ ] Test Docker build
- [ ] Run database migrations
- [ ] Verify API endpoints
- [ ] Test health checks
- [ ] Configure monitoring/logging
- [ ] Set up CI/CD pipeline
- [ ] Document environment-specific access credentials

---

## 🆘 Troubleshooting

### Issue: Container won't start
```bash
docker-compose -f docker-compose.{env}.yml logs api
docker-compose -f docker-compose.{env}.yml ps
```

### Issue: Database connection failed
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Test connection
docker exec -it {postgres-container} psql -U postgres -d {database-name}
```

### Issue: Port already in use
```bash
# Find process using port
lsof -i :8081
kill -9 {PID}
```

---

## 📞 Support

For questions or issues, contact the development team or refer to:
- [README.md](README.md)
- [EC2-DEPLOYMENT.md](EC2-DEPLOYMENT.md)

---

**Last Updated:** January 9, 2026
