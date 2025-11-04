#!/bin/bash
set -e  # Exit on any error

echo "[INFO] Deploying demo application..."

# Check for port conflicts
if docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -q ":3000->"; then
    echo "[ERROR] Port 3000 is already in use by another container"
    docker ps --format "table {{.Names}}\t{{.Ports}}" | grep ":3000->"
    exit 1
fi

# Run the demo application
echo "[DEBUG] Starting demo-app container..."
docker run -d \
    --name demo-app \
    --network devops-net \
    -p 3000:80 \
    --restart unless-stopped \
    demo-app:latest

# Wait for application to be ready
echo "[DEBUG] Waiting for application to start..."
sleep 5

# Test application health
echo "[DEBUG] Testing application health..."
for i in {1..5}; do
    if curl -f http://localhost:3000 >/dev/null 2>&1; then
        echo "[INFO] ✅ Demo application is running successfully!"
        echo "[INFO] 🌐 Access the app at: http://localhost:3000"
        break
    else
        echo "[DEBUG] App not ready yet, waiting... ($i/5)"
        sleep 3
    fi
done

# Show application info
echo "[INFO] Application deployment completed!"
echo "[INFO] Container: demo-app"
echo "[INFO] Network: devops-net" 
echo "[INFO] Port: 3000 -> 80"
echo "[INFO] URL: http://localhost:3000"