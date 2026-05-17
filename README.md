# Final Project Deployment Guide

## Symfony Docker Deployment (Railway & Other Hosting Platforms)

This project demonstrates how to containerize and deploy a Symfony application using Docker and related technologies.

---

## Technologies Used

The application is deployed using:

- Docker
- Nginx
- PHP-FPM
- MySQL
- Docker Compose

---

## Project Objectives

This project is designed to demonstrate understanding of:

- Containerized application deployment
- Symfony production configuration
- Docker networking and orchestration
- Web server configuration using Nginx
- Environment variable management
- Cloud deployment workflows (e.g., Railway)

---

## Project Requirements

Your final project must include:

- A working Symfony application
- Dockerized deployment setup
- Proper Nginx configuration
- Production-ready environment configuration
- Database integration
- Complete deployment documentation
- Successful deployment on a hosting platform (e.g., Railway)

---

## Required Files

Create the following files in your project root directory:

### Dockerfile

Defines the blueprint for building the application’s Docker image.  
Without it, the application cannot be containerized or deployed consistently across environments.

---

### docker-compose.yaml

Defines and manages multiple containers as a single application stack (primarily for local development).  
Ensures all services work together as a complete system and simplifies container orchestration.

---

### entrypoint.sh

Script executed when a container starts.  
Ensures the application initializes in a consistent and production-ready state every time.

---

### nginx.conf

Main configuration file for the Nginx web server.  
Acts as the entry point for all web traffic and forwards requests correctly to the application.

---

### nginx-main.conf

Additional or environment-specific Nginx configuration file.  
Improves maintainability and allows safer updates without modifying the main config.

---

### .dockerignore

Specifies files and folders excluded from the Docker build context.  
Helps keep Docker images clean and builds efficient.

---

### .env

Stores environment variables used by the application.  
Keeps sensitive information out of the codebase and allows flexible configuration across environments.

---

## Deployment Notes

- Ensure all environment variables are properly set before deployment
- Verify database connection settings in `.env`
- Use production mode for Symfony in deployment
- Confirm Nginx is correctly routing requests to PHP-FPM
- Test Docker Compose setup locally before deployment

---

## Local Development Setup

### Prerequisites
- Docker and Docker Compose installed
- Git

### Steps

1. Clone the repository:
```bash
git clone <repository-url>
cd platform-deployment-final-project
```

2. Configure environment variables:
```bash
cp .env.production .env.local
# Edit .env.local with your local development values
```

3. Build and start the containers:
```bash
docker-compose up --build
```

4. Access the application at `http://localhost`

5. Run database migrations:
```bash
docker-compose exec php php bin/console doctrine:migrations:migrate
```

6. Stop the containers:
```bash
docker-compose down
```

---

## Railway Deployment

### Prerequisites
- Railway account
- GitHub repository with the project

### Steps

1. **Prepare your repository**
   - Push all files to GitHub
   - Ensure `.env.production` is NOT committed (add to `.gitignore`)
   - Commit all Docker configuration files

2. **Create Railway project**
   - Go to [railway.app](https://railway.app)
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository

3. **Configure services**
   
   Railway will automatically detect your `docker-compose.yml` and create services. You may need to adjust the configuration:

   **For the PHP service:**
   - Set root directory to `.`
   - Use the Dockerfile
   - Environment variables:
     - `APP_ENV=prod`
     - `APP_SECRET=<generate-a-secure-secret>`
     - `DATABASE_URL=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQLHOST}:${MYSQLPORT}/${MYSQLDATABASE}?serverVersion=8.0.32&charset=utf8mb4`

   **For the MySQL service:**
   - Railway provides a managed MySQL service
   - Set environment variables:
     - `MYSQL_ROOT_PASSWORD=<secure-password>`
     - `MYSQL_USER=<username>`
     - `MYSQL_PASSWORD=<secure-password>`
     - `MYSQL_DATABASE=<database-name>`

   **For the Nginx service:**
   - Use the provided nginx configuration
   - Expose port 80

4. **Set environment variables in Railway**
   - Go to each service's "Variables" tab
   - Add the required environment variables from `.env.production`
   - Railway will inject these into your containers

5. **Deploy**
   - Railway will automatically deploy when you push to GitHub
   - Monitor the deployment logs in the Railway dashboard

6. **Access your application**
   - Railway will provide a public URL for your application
   - The URL will be in the format: `https://<project-name>.railway.app`

### Railway-Specific Configuration

Create a `railway.yaml` file in your project root for Railway-specific settings:

```yaml
build:
  builder: dockerfile
  dockerfilePath: ./Dockerfile

deploy:
  startCommand: php-fpm
  healthcheckPath: /
```

### Troubleshooting Railway Deployment

- **Database connection issues**: Ensure the `DATABASE_URL` uses Railway's provided database host
- **Permission errors**: The entrypoint script handles permissions, but verify the `var/` directory is writable
- **Cache issues**: Clear cache by redeploying or using the Railway console
- **Nginx routing**: Check that Nginx is correctly forwarding to the PHP service

---

## Deployment Platform

Recommended platform:

- Railway

Alternative platforms:
- AWS ECS
- Google Cloud Run
- Azure Container Instances
- DigitalOcean App Platform

## Notes

This project is intended for educational purposes and demonstrates full-stack containerized deployment practices using Symfony.

## What to submit

- Link of your application
- Recorded video containing (5-10 mins):
    - Explanation of the Dockerfile setup (1–2 mins)
    - Explanation of the Nginx configuration (1–2 mins)
    - Environment variable setup overview (1 min)
    - Deployment process walkthrough (2–3 mins)
    - Final proof that the deployed version is working correctly (1–2 mins)

## Grading Rubric (Total: 100 Points)

| Category                              | Description                                           | Points |
| ------------------------------------- | ----------------------------------------------------- | ------ |
| **Docker Setup**                      | Dockerfile and docker-compose are correct and working | 25     |
| **Nginx Configuration**               | Correct routing to PHP-FPM and proper Symfony setup   | 15     |
| **Symfony Production Setup**          | Production mode, caching, and stable runtime          | 15     |
| **Environment & Security**            | Proper .env usage and secure configuration            | 10     |
| **Database Integration**              | Working database connection and CRUD/migrations       | 10     |
| **Deployment**                        | Successfully deployed and accessible live application | 15     |
| **Understanding (Video Explanation)** | Clear explanation of Docker, Nginx, and deployment    | 7      |
| **Video Presentation Quality**        | Clear, complete, and within 5–10 minutes              | 3      |
