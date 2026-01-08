# EC2 Deployment Guide - Order Management System API

Complete guide for deploying the Order Management System API on an AWS EC2 Linux instance.

## Prerequisites

- AWS EC2 instance (Amazon Linux 2 or Ubuntu)
- SSH access to the instance
- Security Group configured
- Domain/Public DNS (optional)

---

## Part 1: EC2 Instance Setup

### 1.1 Launch EC2 Instance

**Recommended Specifications:**
- **AMI:** Amazon Linux 2023 or Ubuntu 22.04
- **Instance Type:** t2.micro (free tier) or t2.small
- **Storage:** 15 GB minimum
- **Key Pair:** Create/select for SSH access

### 1.2 Configure Security Group

Add the following **Inbound Rules**:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| Custom TCP | TCP | 8081 | 0.0.0.0/0 | API access |
| Custom TCP | TCP | 5432 | Your IP | PostgreSQL (optional) |
| HTTP | TCP | 80 | 0.0.0.0/0 | HTTP (optional) |
| HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS (optional) |

**Important:** Restrict 0.0.0.0/0 to your IP for production!

---

## Part 2: Connect to EC2 Instance

### 2.1 SSH Connection

```bash
# Using your key pair
ssh -i /path/to/your-key.pem ec2-user@YOUR-EC2-PUBLIC-DNS

# For Ubuntu instances
ssh -i /path/to/your-key.pem ubuntu@YOUR-EC2-PUBLIC-DNS
```

### 2.2 Update System

```bash
# Amazon Linux
sudo yum update -y

# Ubuntu
sudo apt update && sudo apt upgrade -y
```

---

## Part 3: Install Required Software

### 3.1 Install Docker

**For Amazon Linux 2023:**
```bash
# Install Docker
sudo yum install -y docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (to run without sudo)
sudo usermod -a -G docker ec2-user

# Log out and back in for group changes to take effect
exit
# SSH back in
```

**For Ubuntu:**
```bash
# Install Docker
sudo apt install -y docker.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -a -G docker ubuntu

# Log out and back in
exit
# SSH back in
```

### 3.2 Install Docker Compose

```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version
```

### 3.3 Install .NET SDK (for migrations)

**For Amazon Linux:**
```bash
# Add Microsoft package repository
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

# Install .NET SDK
sudo yum install -y dotnet-sdk-9.0

# Verify
dotnet --version
```

**For Ubuntu:**
```bash
# Add Microsoft package repository
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install .NET SDK
sudo apt update
sudo apt install -y dotnet-sdk-9.0

# Verify
dotnet --version
```

### 3.4 Install Git

```bash
# Amazon Linux
sudo yum install -y git

# Ubuntu
sudo apt install -y git

# Verify
git --version
```

---

## Part 4: Deploy the Application

### 4.1 Clone the Repository

```bash
# Clone your project
cd ~
git clone https://github.com/Mahesh199811/OrderManagement.git

# Navigate to project
cd OrderManagement/OrderManagement.API
```

### 4.2 Build the Application

```bash
# Restore packages
dotnet restore

# Publish the application
dotnet publish -c Release
```

### 4.3 Build Docker Image

```bash
# Build the Docker image
docker build -t order-api .

# Verify image is created
docker images
```

### 4.4 Start Services with Docker Compose

```bash
# Start all services (API + PostgreSQL)
docker-compose up -d

# Check if containers are running
docker ps

# Expected output:
# - order-api-container (running on port 8080)
# - postgres-db (running on port 5432)
```

---

## Part 5: Database Setup

### 5.1 Wait for PostgreSQL to be Ready

```bash
# Wait a few seconds for PostgreSQL to start
sleep 10

# Check if PostgreSQL is ready
docker exec postgres-db pg_isready -U postgres
```

### 5.2 Apply Database Migrations

```bash
# Apply migrations to create database schema
ASPNETCORE_ENVIRONMENT=Development dotnet ef database update

# Verify table was created
docker exec -it postgres-db psql -U postgres -d OrderManagementDb -c '\dt'
```

### 5.3 Verify Database Schema

```bash
# Check Orders table structure
docker exec -it postgres-db psql -U postgres -d OrderManagementDb -c '\d "Orders"'
```

---

## Part 6: Verify Deployment

### 6.1 Test Locally on EC2

```bash
# Test API health (from EC2 instance)
curl http://localhost:8080/api/orders

# Test Swagger UI
curl http://localhost:8080/swagger/index.html
```

### 6.2 Check Container Logs

```bash
# View API logs
docker logs order-api-container

# View database logs
docker logs postgres-db

# Follow logs in real-time
docker logs -f order-api-container
```

### 6.3 Test from Browser

Open your browser and navigate to:
```
http://YOUR-EC2-PUBLIC-DNS:8081/swagger
```

Replace `YOUR-EC2-PUBLIC-DNS` with your actual EC2 public DNS or IP address.

---

## Part 7: Test API Endpoints

### Using Swagger UI
1. Navigate to `http://YOUR-EC2-PUBLIC-DNS:8081/swagger`
2. Try the GET /api/orders endpoint
3. Create an order using POST /api/orders

### Using curl from your local machine

```bash
# Get all orders
curl http://YOUR-EC2-PUBLIC-DNS:8081/api/orders

# Create an order
curl -X POST http://YOUR-EC2-PUBLIC-DNS:8081/api/orders \
  -H "Content-Type: application/json" \
  -d '{"customerName":"John Doe","totalAmount":150.50}'

# Get order by ID
curl http://YOUR-EC2-PUBLIC-DNS:8081/api/orders/1

# Update order
curl -X PUT http://YOUR-EC2-PUBLIC-DNS:8081/api/orders/1 \
  -H "Content-Type: application/json" \
  -d '{"customerName":"Jane Doe","totalAmount":200.00}'

# Delete order
curl -X DELETE http://YOUR-EC2-PUBLIC-DNS:8081/api/orders/1
```

---

## Part 8: Managing the Application

### 8.1 Stop Services

```bash
# Stop all containers
docker-compose down

# Stop and remove volumes (deletes data!)
docker-compose down -v
```

### 8.2 Restart Services

```bash
# Restart all containers
docker-compose restart

# Restart only API
docker restart order-api-container
```

### 8.3 Update Application

```bash
# Pull latest code
cd ~/OrderManagement/OrderManagement.API
git pull

# Rebuild and publish
dotnet publish -c Release

# Rebuild Docker image
docker build -t order-api .

# Restart containers
docker-compose down
docker-compose up -d
```

### 8.4 View Logs

```bash
# View recent logs
docker logs order-api-container --tail 50

# Follow logs in real-time
docker logs -f order-api-container

# View logs with timestamps
docker logs -t order-api-container
```

---

## Part 9: Troubleshooting

### Issue 1: Cannot Access API from Browser

**Symptoms:** API works locally on EC2 but not from browser

**Solutions:**
1. Check Security Group has port 8081 open to 0.0.0.0/0
2. Verify containers are running: `docker ps`
3. Check API is listening on all interfaces (0.0.0.0):
   ```bash
   docker logs order-api-container | grep "Now listening"
   ```

### Issue 2: Database Connection Error

**Symptoms:** 500 Internal Server Error when calling API

**Solutions:**
1. Check if PostgreSQL is running:
   ```bash
   docker ps | grep postgres-db
   docker exec postgres-db pg_isready -U postgres
   ```

2. Verify connection string in docker-compose.yml
3. Check database migrations are applied:
   ```bash
   ASPNETCORE_ENVIRONMENT=Development dotnet ef database update
   ```

4. Check API can reach database:
   ```bash
   docker exec order-api-container ping postgres-db -c 2
   ```

### Issue 3: Container Keeps Restarting

**Check logs:**
```bash
docker logs order-api-container --tail 100
```

**Common causes:**
- Port already in use
- Missing environment variables
- Database not accessible
- Application crash on startup

### Issue 4: Out of Memory

**Check container resource usage:**
```bash
docker stats
```

**Solution:** Upgrade to larger EC2 instance (t2.small or t2.medium)

### Issue 5: Permission Denied

**Solution:**
```bash
# Add user to docker group
sudo usermod -a -G docker $USER

# Log out and back in
exit
# SSH back in
```

---

## Part 10: Production Best Practices

### 10.1 Security Hardening

```bash
# 1. Restrict Security Group
# Change source from 0.0.0.0/0 to specific IPs

# 2. Use HTTPS (optional - requires SSL certificate)
# Install Nginx or use AWS Load Balancer

# 3. Change default passwords
# Update PostgreSQL password in docker-compose.yml

# 4. Enable firewall
sudo yum install -y firewalld  # Amazon Linux
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```

### 10.2 Backup Database

```bash
# Create backup
docker exec postgres-db pg_dump -U postgres OrderManagementDb > backup.sql

# Restore backup
cat backup.sql | docker exec -i postgres-db psql -U postgres OrderManagementDb
```

### 10.3 Monitor Application

```bash
# Check container health
docker ps
docker stats

# Set up log rotation
# Docker automatically handles log rotation

# Monitor disk space
df -h
```

### 10.4 Auto-start on Reboot

```bash
# Docker service is already enabled

# For additional automation, create systemd service:
sudo nano /etc/systemd/system/order-api.service
```

Add:
```ini
[Unit]
Description=Order Management API
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/OrderManagement/OrderManagement.API
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl daemon-reload
sudo systemctl enable order-api
```

---

## Part 11: Quick Reference Commands

### Container Management
```bash
# List all containers
docker ps -a

# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# Restart containers
docker-compose restart

# View logs
docker logs order-api-container
docker logs postgres-db

# Execute command in container
docker exec -it order-api-container bash
docker exec -it postgres-db psql -U postgres -d OrderManagementDb
```

### Database Operations
```bash
# Apply migrations
ASPNETCORE_ENVIRONMENT=Development dotnet ef database update

# Access database
docker exec -it postgres-db psql -U postgres -d OrderManagementDb

# List tables
docker exec -it postgres-db psql -U postgres -d OrderManagementDb -c '\dt'

# View table data
docker exec -it postgres-db psql -U postgres -d OrderManagementDb -c 'SELECT * FROM "Orders";'
```

### Application Updates
```bash
# Pull latest code
git pull

# Rebuild
dotnet publish -c Release
docker build -t order-api .

# Restart
docker-compose down && docker-compose up -d
```

---

## Part 12: Getting Public DNS/IP

### Find EC2 Public DNS

**From AWS Console:**
1. Go to EC2 → Instances
2. Select your instance
3. Copy "Public IPv4 DNS" or "Public IPv4 address"

**From EC2 instance:**
```bash
# Get public IP
curl http://checkip.amazonaws.com

# Get instance metadata
curl http://169.254.169.254/latest/meta-data/public-ipv4
curl http://169.254.169.254/latest/meta-data/public-hostname
```

---

## Summary Checklist

- ✅ EC2 instance launched with appropriate instance type
- ✅ Security Group configured (ports 22, 8080, 5432)
- ✅ Docker and Docker Compose installed
- ✅ .NET SDK installed
- ✅ Git installed
- ✅ Repository cloned
- ✅ Application published
- ✅ Docker image built
- ✅ Containers started with docker-compose
- ✅ Database migrations applied
- ✅ API accessible via public DNS
- ✅ API tested with Swagger UI

---

## Support

If you encounter issues:
1. Check container logs: `docker logs order-api-container`
2. Verify containers are running: `docker ps`
3. Test locally on EC2: `curl http://localhost:8080/swagger/index.html`
4. Check Security Group inbound rules
5. Review this troubleshooting guide

**Repository:** https://github.com/Mahesh199811/OrderManagement

**API Endpoint:** http://YOUR-EC2-PUBLIC-DNS:8080/swagger
