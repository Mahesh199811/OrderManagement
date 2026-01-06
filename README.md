# Order Management System API

A RESTful API for managing orders built with .NET 9, Entity Framework Core, and PostgreSQL, fully containerized with Docker.

## Features

- Full CRUD operations for orders
- PostgreSQL database integration
- Entity Framework Core with migrations
- Swagger UI for API documentation
- Docker and Docker Compose support

## Tech Stack

- .NET 9.0
- Entity Framework Core 9.0
- PostgreSQL 15
- Npgsql (PostgreSQL provider)
- Swagger/OpenAPI
- Docker

## Project Structure

```
OrderManagementSystem/
├── OrderManagement.API/
│   ├── Controllers/
│   │   └── OrdersController.cs
│   ├── Models/
│   │   └── Order.cs
│   ├── Data/
│   │   └── AppDbContext.cs
│   ├── DTOs/
│   │   ├── CreateOrderDto.cs
│   │   └── UpdateOrderDto.cs
│   ├── Migrations/
│   ├── Dockerfile
│   └── appsettings.json
├── docker-compose.yml
└── README.md
```

## Dockerization Steps

### 1. Create Dockerfile

Create a `Dockerfile` in the `OrderManagement.API` directory:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY bin/Release/net9.0/publish/ .
ENTRYPOINT ["dotnet", "OrderManagement.API.dll"]
```

### 2. Publish the Application

Build and publish the .NET application in Release configuration:

```bash
cd OrderManagement.API
dotnet publish -c Release
```

### 3. Build Docker Image

Build the Docker image from the Dockerfile:

```bash
docker build -t order-api .
```

### 4. Run PostgreSQL Container

Start a PostgreSQL container:

```bash
docker run -d \
  --name postgres-db \
  -e POSTGRES_DB=OrderManagementDb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15
```

### 5. Run API Container

Run the API container and link it to the PostgreSQL container:

```bash
docker run -d \
  -p 8080:8080 \
  --name order-api-container \
  --network bridge \
  --link postgres-db:postgres-db \
  order-api
```

### 6. Database Migrations

Apply Entity Framework Core migrations to create the database schema:

```bash
# Install EF Core tools (if not already installed)
dotnet tool install --global dotnet-ef

# Create initial migration
dotnet ef migrations add InitialCreate

# Apply migrations to database
ASPNETCORE_ENVIRONMENT=Development dotnet ef database update
```

## Using Docker Compose

For easier deployment, use Docker Compose to run both services together.

### docker-compose.yml

```yaml
services:
  postgres:
    image: postgres:15
    container_name: postgres-db
    environment:
      POSTGRES_DB: OrderManagementDb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"

  api:
    image: order-api
    container_name: order-api-container
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    environment:
      ConnectionStrings__DefaultConnection: Host=postgres;Port=5432;Database=OrderManagementDb;Username=postgres;Password=postgres
```

### Start Services with Docker Compose

```bash
# Start all services
docker-compose up -d

# View running services
docker-compose ps

# View logs
docker-compose logs

# Stop all services
docker-compose down
```

## Docker Commands Reference

### Container Management

```bash
# List all containers
docker ps -a

# Start a container
docker start <container-name>

# Stop a container
docker stop <container-name>

# Remove a container
docker rm <container-name>

# View container logs
docker logs <container-name>

# Execute command in running container
docker exec -it <container-name> <command>
```

### Image Management

```bash
# List all images
docker images

# Remove an image
docker rmi <image-name>

# Build an image
docker build -t <image-name> .

# Pull an image from registry
docker pull <image-name>
```

### Network Commands

```bash
# List networks
docker network ls

# Create a network
docker network create <network-name>

# Connect container to network
docker network connect <network-name> <container-name>
```

### Database Access

Access PostgreSQL database directly:

```bash
docker exec -it postgres-db psql -U postgres -d OrderManagementDb
```

View table schema:

```bash
docker exec -it postgres-db psql -U postgres -d OrderManagementDb -c '\d "Orders"'
```

## API Endpoints

### Base URL
```
http://localhost:8080
```

### Swagger Documentation
```
http://localhost:8080/swagger
```

### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/orders` | Get all orders |
| GET | `/api/orders/{id}` | Get order by ID |
| POST | `/api/orders` | Create new order |
| PUT | `/api/orders/{id}` | Update existing order |
| DELETE | `/api/orders/{id}` | Delete order |

## Testing the API

### Using HTTP File

Use the `OrderManagement.API.http` file with REST Client extension in VS Code:

```http
### Get all orders
GET http://localhost:8080/api/orders

### Create a new order
POST http://localhost:8080/api/orders
Content-Type: application/json

{
  "customerName": "John Doe",
  "totalAmount": 150.50
}

### Update an order
PUT http://localhost:8080/api/orders/1
Content-Type: application/json

{
  "customerName": "John Doe Updated",
  "totalAmount": 200.75
}

### Delete an order
DELETE http://localhost:8080/api/orders/1
```

### Using cURL

```bash
# Get all orders
curl http://localhost:8080/api/orders

# Create an order
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"customerName":"John Doe","totalAmount":150.50}'

# Get order by ID
curl http://localhost:8080/api/orders/1

# Update an order
curl -X PUT http://localhost:8080/api/orders/1 \
  -H "Content-Type: application/json" \
  -d '{"customerName":"John Updated","totalAmount":200.75}'

# Delete an order
curl -X DELETE http://localhost:8080/api/orders/1
```

## Troubleshooting

### Container Connection Issues

If the API can't connect to PostgreSQL:

1. Ensure both containers are on the same network
2. Use the container name as the host in connection string
3. Check connection string in `appsettings.json`

### Port Already in Use

If port 8080 or 5432 is already in use:

```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>
```

### View Container Logs

```bash
# API logs
docker logs order-api-container

# Database logs
docker logs postgres-db

# Follow logs in real-time
docker logs -f order-api-container
```

## Development

### Local Development Setup

1. Clone the repository
2. Run PostgreSQL locally or via Docker
3. Update connection string in `appsettings.Development.json`
4. Apply migrations: `dotnet ef database update`
5. Run the application: `dotnet run`

### Building for Production

```bash
# Clean previous builds
dotnet clean

# Publish in Release mode
dotnet publish -c Release

# Build Docker image
docker build -t order-api .

# Push to registry (optional)
docker tag order-api:latest <registry>/order-api:latest
docker push <registry>/order-api:latest
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ConnectionStrings__DefaultConnection` | PostgreSQL connection string | See appsettings.json |
| `ASPNETCORE_ENVIRONMENT` | Application environment | Production |

## License

MIT

## Author

Mahesh Gadhave
