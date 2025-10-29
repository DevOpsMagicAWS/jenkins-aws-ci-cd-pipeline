# Demo Application

This directory contains a simple web application used to demonstrate the CI/CD pipeline.

## Files Overview

### `Dockerfile`
**Purpose**: Container configuration for the demo web application

**Base Image**: `nginx:alpine`
**Port**: 80 (HTTP)
**Content**: Serves static HTML from nginx

### `index.html`
**Purpose**: Simple HTML page demonstrating the application

**Content**: 
- Title: "Devops Demo App"
- Header: "CI/CD Pipeline Demo with Jenkins + Terraform + AWS"

## Application Architecture

```
┌─────────────┐    HTTP :80    ┌─────────────┐
│   Browser   │◄──────────────►│    nginx    │
│             │                │   Alpine    │
└─────────────┘                └─────────────┘
                                      │
                                ┌─────────────┐
                                │ index.html  │
                                └─────────────┘
```

## Build and Run

### Build Docker Image
```bash
cd app
docker build -t demo-app:latest .
```

### Run Container
```bash
docker run -d --name demo-app -p 3000:80 demo-app:latest
```

### Access Application
- **URL**: http://localhost:3000
- **Content**: Simple HTML page with pipeline demo message

### Stop Container
```bash
docker stop demo-app
docker rm demo-app
```

## CI/CD Integration

The application is integrated into the Jenkins pipeline:

### Pipeline Stages
1. **Build Stage**: `docker build -t demo-app:latest .`
2. **Deploy Stage**: Container can be deployed after infrastructure
3. **Cleanup**: Container is stopped and removed automatically

### Jenkins Pipeline Usage
```groovy
stage('Build Docker Image') {
    steps {
        dir('app') {
            sh 'docker build -t demo-app:latest .'
        }
    }
}
```

## Customization

### Modify Content
Edit `index.html` to change the application content:
```html
<!DOCTYPE html>
<html>
    <head>
        <title>Your Custom Title</title>
    </head>
    <body>
        <h1>Your Custom Message</h1>
    </body>
</html>
```

### Add Static Assets
- Place CSS files in the same directory
- Reference them in `index.html`
- They will be copied to the nginx container

### Advanced Configuration
- Modify `Dockerfile` to add custom nginx configuration
- Add environment variables for dynamic content
- Include build steps for compiled assets