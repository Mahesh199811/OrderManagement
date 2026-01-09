# 🚀 Quick Start Guide - Environment Management

## What Has Been Set Up

Your Order Management System now has a complete environment management strategy with:

✅ **4 Environment Configurations**: DEV, QA, Staging, Production  
✅ **Git Branching Strategy**: develop → qa → staging → main  
✅ **Environment-specific Docker files**  
✅ **Automated deployment scripts**  
✅ **CI/CD workflows (GitHub Actions)**  
✅ **Security best practices**

---

## 📁 Files Created

### Configuration Files
- `appsettings.Development.json` - Development settings
- `appsettings.QA.json` - QA environment settings
- `appsettings.Staging.json` - Staging environment settings
- `appsettings.Production.json` - Production environment settings
- `.env.example` - Template for environment variables

### Docker Files
- `Dockerfile.dev` - Development container
- `Dockerfile.qa` - QA container
- `Dockerfile.staging` - Staging container
- `Dockerfile.prod` - Production container (with security hardening)

### Docker Compose Files
- `docker-compose.dev.yml` - Dev environment (port 8081)
- `docker-compose.qa.yml` - QA environment (port 8082)
- `docker-compose.staging.yml` - Staging environment (port 8083)
- `docker-compose.prod.yml` - Production environment (port 8080)

### Scripts
- `setup-branches.sh` - Automated Git branch setup
- `deploy.sh` - Deployment script for all environments

### CI/CD Workflows
- `.github/workflows/deploy-dev.yml` - Auto-deploy on push to develop
- `.github/workflows/deploy-qa.yml` - Auto-deploy on push to qa
- `.github/workflows/deploy-staging.yml` - Auto-deploy on push to staging
- `.github/workflows/deploy-prod.yml` - Auto-deploy on push to main

### Documentation
- `ENVIRONMENT-SETUP.md` - Complete environment configuration guide

---

## 🎯 First Steps

### 1. Set Up Git Branches

```bash
# Run the automated branch setup
./setup-branches.sh

# Or manually:
git checkout -b develop
git push -u origin develop

git checkout -b qa
git push -u origin qa

git checkout -b staging
git push -u origin staging

git checkout main
```

### 2. Create Environment Files

```bash
cd OrderManagement.API

# Create environment-specific .env files
cp .env.example .env.dev
cp .env.example .env.qa
cp .env.example .env.staging
cp .env.example .env.prod

# Edit each file with appropriate values
nano .env.dev   # or use your preferred editor
nano .env.qa
nano .env.staging
nano .env.prod
```

### 3. Test Local Development

```bash
# Deploy to local development
./deploy.sh dev

# Or manually:
cd OrderManagement.API
docker-compose -f docker-compose.dev.yml up --build
```

**Access your API:**
- API: http://localhost:8081
- Swagger: http://localhost:8081/swagger
- Health: http://localhost:8081/health

---

## 🌍 Environment Endpoints

| Environment | Branch | Port | Swagger | Database |
|------------|--------|------|---------|----------|
| **Development** | develop | 8081 | ✅ Enabled | localhost:5432 |
| **QA** | qa | 8082 | ✅ Enabled | localhost:5433 |
| **Staging** | staging | 8083 | ✅ Enabled | localhost:5434 |
| **Production** | main | 8080 | ❌ Disabled | External RDS/managed |

---

## 🔄 Typical Workflow

### 1. **Feature Development** (develop branch)

```bash
git checkout develop
git pull origin develop
git checkout -b feature/add-customer-api

# Make your changes
git add .
git commit -m "feat: add customer API endpoints"
git push origin feature/add-customer-api

# Create PR to develop branch
```

### 2. **Test in QA** (qa branch)

```bash
# After PR is merged to develop
git checkout qa
git merge develop
git push origin qa

# Automatically deploys to QA environment
```

### 3. **Test in Staging** (staging branch)

```bash
# After QA testing passes
git checkout staging
git merge qa
git push origin staging

# Automatically deploys to Staging environment
```

### 4. **Release to Production** (main branch)

```bash
# After Staging approval
git checkout main
git merge staging
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags

# Automatically deploys to Production environment
```

---

## 🔧 Deployment Commands

### Using the Deploy Script (Recommended)

```bash
# Deploy to any environment
./deploy.sh dev       # Development
./deploy.sh qa        # QA
./deploy.sh staging   # Staging
./deploy.sh prod      # Production (requires confirmation)
```

### Manual Deployment

```bash
# Development
cd OrderManagement.API
docker-compose -f docker-compose.dev.yml up --build -d

# QA
export DB_PASSWORD="your-qa-password"
docker-compose -f docker-compose.qa.yml up --build -d

# Staging
export DB_PASSWORD="your-staging-password"
docker-compose -f docker-compose.staging.yml up --build -d

# Production
export DB_HOST="prod-db-host.com"
export DB_NAME="OrderManagementDb_Prod"
export DB_USER="prod_user"
export DB_PASSWORD="your-prod-password"
docker-compose -f docker-compose.prod.yml up --build -d
```

### View Logs

```bash
# View logs for any environment
docker-compose -f docker-compose.dev.yml logs -f api
docker-compose -f docker-compose.qa.yml logs -f api
docker-compose -f docker-compose.staging.yml logs -f api
docker-compose -f docker-compose.prod.yml logs -f api
```

### Stop Environments

```bash
# Stop any environment
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.qa.yml down
docker-compose -f docker-compose.staging.yml down
docker-compose -f docker-compose.prod.yml down
```

---

## 🔐 Security Checklist

- [ ] Never commit `.env` files (already in .gitignore)
- [ ] Use strong passwords for each environment
- [ ] Store production credentials in secrets manager (AWS Secrets Manager, Azure Key Vault)
- [ ] Enable branch protection rules on main, staging, and qa branches
- [ ] Require PR reviews before merging to main
- [ ] Set up GitHub Secrets for CI/CD workflows
- [ ] Use different database passwords for each environment
- [ ] Disable Swagger in production (already configured)
- [ ] Enable HTTPS in production
- [ ] Use non-root user in production Docker container (already configured)

---

## 📊 GitHub Secrets Setup

Add these secrets in your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

### QA Environment
- `QA_DB_PASSWORD`

### Staging Environment
- `STAGING_DB_PASSWORD`

### Production Environment
- `PROD_DB_HOST`
- `PROD_DB_NAME`
- `PROD_DB_USER`
- `PROD_DB_PASSWORD`

---

## 🧪 Testing Each Environment

```bash
# Development
curl http://localhost:8081/health
curl http://localhost:8081/api/orders

# QA
curl http://localhost:8082/health
curl http://localhost:8082/api/orders

# Staging
curl http://localhost:8083/health
curl http://localhost:8083/api/orders

# Production
curl http://localhost:8080/health
curl http://localhost:8080/api/orders
```

---

## 📖 Additional Resources

- Full documentation: [ENVIRONMENT-SETUP.md](ENVIRONMENT-SETUP.md)
- EC2 Deployment: [EC2-DEPLOYMENT.md](EC2-DEPLOYMENT.md)
- Project README: [README.md](README.md)

---

## 🆘 Common Issues

### Port Already in Use
```bash
# Find and kill process
lsof -i :8081
kill -9 <PID>
```

### Database Connection Failed
```bash
# Check if container is running
docker ps | grep postgres

# Check logs
docker logs <postgres-container-name>

# Restart container
docker restart <postgres-container-name>
```

### Migration Errors
```bash
# Run migrations manually
docker exec <api-container-name> dotnet ef database update
```

---

## ✅ Next Steps

1. ✅ Run `./setup-branches.sh` to create Git branches
2. ✅ Create `.env` files for each environment
3. ✅ Test local development with `./deploy.sh dev`
4. ✅ Push your code to GitHub
5. ✅ Configure GitHub Secrets
6. ✅ Set branch protection rules
7. ✅ Deploy to QA/Staging/Prod as needed

---

**Need Help?** Refer to [ENVIRONMENT-SETUP.md](ENVIRONMENT-SETUP.md) for detailed instructions.

**Happy Deploying! 🚀**
