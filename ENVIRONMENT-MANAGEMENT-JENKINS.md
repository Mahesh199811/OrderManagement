# Managing Environment-Specific Code in EC2 Instance

This document provides a step-by-step guide to manage environment-specific code in an EC2 instance and create a Jenkins pipeline for automated deployment.

---

## **Managing Environment-Specific Code in EC2 Instance**

### **1. Directory Structure**
Organize your project to separate environment-specific files:

```
/OrderManagementSystem
├── Dockerfile
├── docker-compose.dev.yml
├── docker-compose.staging.yml
├── docker-compose.prod.yml
├── appsettings.json
├── appsettings.Development.json
├── appsettings.Staging.json
├── appsettings.Production.json
├── .env.dev
├── .env.staging
├── .env.prod
```

### **2. Use `.env` Files for Environment Variables**
Store sensitive or environment-specific values in `.env` files:

- `.env.dev`:
  ```env
  DB_HOST=localhost
  DB_USER=dev_user
  DB_PASSWORD=dev_password
  EXTERNAL_PORT=8084
  ```
- `.env.prod`:
  ```env
  DB_HOST=prod-db.example.com
  DB_USER=prod_user
  DB_PASSWORD=prod_password
  EXTERNAL_PORT=8080
  ```

### **3. Deploy Environment-Specific Code**

1. **Copy Files to EC2 Instance**:
   Use `scp` to copy your project files to the EC2 instance:
   ```bash
   scp -i your-key.pem -r /path/to/OrderManagementSystem ec2-user@<EC2_PUBLIC_IP>:/home/ec2-user/
   ```

2. **Navigate to the Project Directory**:
   ```bash
   cd /home/ec2-user/OrderManagementSystem
   ```

3. **Run Docker Compose for the Target Environment**:
   Use the appropriate `docker-compose` file and `.env` file:
   ```bash
   docker-compose --env-file .env.prod -f docker-compose.prod.yml up -d
   ```

4. **Verify the Deployment**:
   Check if the containers are running:
   ```bash
   docker ps
   ```
   Access the application at `http://<EC2_PUBLIC_IP>:<EXTERNAL_PORT>`.

---

## **Creating a Jenkins Pipeline**

### **1. Install Jenkins on EC2**

#### **1.1. Install Jenkins on Amazon Linux**

1. **Install Java**:
   ```bash
   sudo yum install java-11-openjdk -y
   ```

2. **Install Jenkins**:
   ```bash
   sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
   sudo yum install jenkins -y
   ```

3. **Start Jenkins**:
   ```bash
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   ```

4. **Access Jenkins**:
   Open `http://<EC2_PUBLIC_IP>:8080` in your browser and follow the setup instructions.

#### **1.2. Install Jenkins on Ubuntu**

1. **Install Java**:
   ```bash
   sudo apt update -y
   sudo apt install openjdk-11-jdk -y
   ```

2. **Install Jenkins**:
   ```bash
   sudo apt install curl -y
   curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee "/usr/share/keyrings/jenkins-keyring.asc" > /dev/null
   echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee "/etc/apt/sources.list.d/jenkins.list" > /dev/null
   sudo apt update -y
   sudo apt install jenkins -y
   ```

3. **Start Jenkins**:
   ```bash
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   ```

4. **Access Jenkins**:
   Open `http://<EC2_PUBLIC_IP>:8080` in your browser and follow the setup instructions.

### **2. Configure Jenkins Pipeline**

1. **Create a New Pipeline**:
   - Go to Jenkins Dashboard → New Item → Pipeline → Name it (e.g., `OrderManagementPipeline`).

2. **Set Up Pipeline Script**:
   Use the following pipeline script:

   ```groovy
   pipeline {
       agent any

       environment {
           ENV_FILE = '.env.prod'
           COMPOSE_FILE = 'docker-compose.prod.yml'
       }

       stages {
           stage('Clone Repository') {
               steps {
                   git 'https://github.com/your-repo/OrderManagementSystem.git'
               }
           }

           stage('Build and Deploy') {
               steps {
                   sh "docker-compose --env-file ${ENV_FILE} -f ${COMPOSE_FILE} down"
                   sh "docker-compose --env-file ${ENV_FILE} -f ${COMPOSE_FILE} up -d"
               }
           }
       }
   }
   ```

3. **Save and Run the Pipeline**:
   - Save the pipeline and click `Build Now` to trigger the deployment.

### **3. Automate Triggering**

1. **Set Up Webhook**:
   - Configure a webhook in your Git repository to notify Jenkins of changes to the `dev` branch.

2. **Configure Jenkins**:
   - In the pipeline configuration, enable the `GitHub hook trigger for GITScm polling` option.

---

## **Summary**
- Organize environment-specific files using `.env` and `docker-compose` files.
- Use Jenkins to automate the deployment process with a pipeline.
- Ensure proper separation of development, staging, and production environments.

Let me know if you need further assistance!