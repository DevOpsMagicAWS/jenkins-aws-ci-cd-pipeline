# Architecture Diagram

## ASCII Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Docker Host (devops-net)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐         │
│  │     Jenkins     │    │   LocalStack    │    │    Demo App     │         │
│  │    Container    │    │   Container     │    │   Container     │         │
│  │                 │    │                 │    │                 │         │
│  │  Port: 8080     │    │  Port: 4566     │    │  Port: 3000     │         │
│  │  Port: 50000    │    │                 │    │                 │         │
│  │                 │    │  Services:      │    │  nginx:alpine   │         │
│  │  Tools:         │    │  - S3           │    │                 │         │
│  │  - Docker CLI   │    │  - IAM          │    │  Serves:        │         │
│  │  - Terraform    │    │                 │    │  - index.html   │         │
│  │  - Git          │    │                 │    │                 │         │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘         │
│           │                       │                       │                │
│           └───────────────────────┼───────────────────────┘                │
│                                   │                                        │
│                    Container-to-Container Communication                     │
│                         (http://localstack:4566)                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Port Mapping
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Host Machine                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Developer Access:                                                          │
│  • Jenkins UI:    http://localhost:8080                                    │
│  • LocalStack:    http://localhost:4566                                    │
│  • Demo App:      http://localhost:3000                                    │
│                                                                             │
│  File System:                                                              │
│  • Source Code:   /project-root/                                           │
│  • Jenkins Data:  docker volume (jenkins_home)                            │
│  • LocalStack:    ./provision/localstack_data/                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Pipeline Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │───▶│   Jenkins   │───▶│ LocalStack  │───▶│  Demo App   │
│             │    │             │    │             │    │             │
│ Source Code │    │ CI/CD       │    │ AWS Mock    │    │ Web Server  │
│ Jenkinsfile │    │ Pipeline    │    │ S3 + IAM    │    │ nginx       │
│ Terraform   │    │ Automation  │    │ Services    │    │ :3000       │
│ Docker App  │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
   Git Clone         Build & Deploy      Create Resources    Serve Content
   Checkout          Terraform Apply     S3 Bucket          HTML Page
   Validation        Docker Build        IAM Policies       HTTP Response
```

## Component Details

### Jenkins Container
- **Base Image**: Custom (jenkins/jenkins:lts + tools)
- **Ports**: 8080 (UI), 50000 (agents)
- **Volumes**: jenkins_home, docker.sock, project files
- **Tools**: Docker CLI, Terraform CLI, Git, curl
- **Network**: devops-net

### LocalStack Container  
- **Base Image**: localstack/localstack:latest
- **Port**: 4566 (all AWS services)
- **Services**: S3, IAM
- **Persistence**: ./localstack_data/
- **Network**: devops-net

### Demo App Container
- **Base Image**: nginx:alpine
- **Port**: 3000 → 80
- **Content**: Static HTML page
- **Network**: devops-net
- **Lifecycle**: Created and destroyed by pipeline

## Network Communication

1. **Jenkins → LocalStack**: `http://localstack:4566`
2. **Jenkins → Demo App**: `http://demo-app:80` 
3. **Host → All Services**: Port mapping (8080, 4566, 3000)
4. **Internal DNS**: Docker network provides container name resolution