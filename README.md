# 🐍 Snake Game — Containerized Web Application

> **Assignment 2: Containerization and Deployment using Docker & Kubernetes**

---

## 1. Project Overview

A browser-based Snake Game with a persistent leaderboard, fully containerized using Docker and deployed on Kubernetes. Players control a snake, eat food to grow and score points, then submit their name and score to a live leaderboard backed by a REST API and MongoDB database.

The application demonstrates a real-world three-tier architecture:

- **Frontend** — playable HTML5 Canvas Snake game with live leaderboard
- **Backend** — RESTful API that handles score submission and retrieval
- **Database** — MongoDB with persistent storage for score records

---

## 2. Tools & Technologies

| Layer       | Technology            | Version       |
|-------------|----------------------|---------------|
| Frontend    | HTML5, CSS3, JS (ES6) | —             |
| Web Server  | nginx                 | alpine (latest)|
| Backend     | Node.js + Express     | 18-alpine     |
| Database    | MongoDB               | 6-jammy       |
| Container   | Docker                | 24+           |
| Orchestration | Kubernetes (kubectl) | 1.27+        |
| Local K8s   | Minikube              | 1.31+         |
| Compose     | Docker Compose        | v2 (3.8)      |

---

## 3. Application Architecture

```
┌─────────────────────────────────────────────────────┐
│                    USER BROWSER                      │
│         http://localhost:3000  (Docker)              │
│         http://<minikube-ip>:30080  (K8s)            │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP
                       ▼
┌──────────────────────────────────────────────────────┐
│              FRONTEND SERVICE                        │
│         nginx:alpine — serves index.html             │
│         Docker: port 3000  │  K8s NodePort: 30080    │
└──────────────────────┬───────────────────────────────┘
                       │ REST API calls
                       │ GET/POST /scores
                       ▼
┌──────────────────────────────────────────────────────┐
│              BACKEND SERVICE                         │
│         Node.js + Express — REST API                 │
│         Docker: port 5000  │  K8s NodePort: 30500    │
│                                                      │
│   GET  /health   → { status: "ok" }                  │
│   GET  /scores   → top 10 scores (JSON)              │
│   POST /scores   → save { name, score }              │
└──────────────────────┬───────────────────────────────┘
                       │ mongoose
                       ▼
┌──────────────────────────────────────────────────────┐
│              DATABASE SERVICE                        │
│         MongoDB 6 — stores player scores             │
│         Docker: port 27017  │  K8s ClusterIP: 27017  │
│         Volume: mongo-data → /data/db                │
└──────────────────────────────────────────────────────┘
```

---

## 4. Folder Structure

```
snake-game/
├── frontend/
│   ├── Dockerfile          # nginx:alpine serving index.html
│   └── index.html          # Snake game + leaderboard (single file)
├── backend/
│   ├── Dockerfile          # node:18-alpine
│   ├── package.json        # express, cors, mongoose
│   └── server.js           # REST API (GET/POST /scores, GET /health)
├── k8s/
│   ├── pv.yaml             # PersistentVolume (256Mi, hostPath)
│   ├── pvc.yaml            # PersistentVolumeClaim (256Mi)
│   ├── db-deployment.yaml  # MongoDB Deployment + ClusterIP Service
│   ├── backend-deployment.yaml  # Backend Deployment (3 replicas) + NodePort
│   ├── frontend-deployment.yaml # Frontend Deployment (3 replicas) + NodePort
│   └── hpa.yaml            # HPA for backend + frontend (2-5 pods, 70% CPU)
├── docker-compose.yml      # Multi-container setup (Task 2)
└── README.md
```

---

## 5. Task 1 — Docker Build & Run Instructions

Build and run each container individually.

### Step 1 — Build images

```bash
# Build frontend image
docker build -t snake-frontend ./frontend

# Build backend image
docker build -t snake-backend ./backend
```

### Step 2 — Run MongoDB

```bash
docker run -d \
  --name snake-db \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  mongo:6-jammy
```

### Step 3 — Run Backend

```bash
docker run -d \
  --name snake-backend \
  -p 5000:5000 \
  -e MONGO_URI=mongodb://host.docker.internal:27017/snakegame \
  snake-backend
```

### Step 4 — Run Frontend

```bash
docker run -d \
  --name snake-frontend \
  -p 3000:80 \
  snake-frontend
```

### Step 5 — Verify

```bash
# Check all containers are running
docker ps

# Test the health endpoint
curl http://localhost:5000/health

# Open the game in your browser
# http://localhost:3000
```

---

## 6. Task 2 — Docker Compose Setup ✅ COMPLETED

Run all three services with a single command.

### Prerequisites

Before running `docker compose up`, pull the MongoDB image to avoid pull timeout issues:

```bash
# Pre-pull MongoDB image (IMPORTANT: do this first)
docker pull mongo:6-jammy

# Then start all services
docker compose up -d
```

### Commands

```bash
# Start all services (builds images automatically)
docker compose up --build -d

# Check running containers
docker compose ps

# View logs for all services
docker compose logs -f

# View logs for a specific service
docker compose logs -f backend

# Stop all services
docker compose down

# Stop and remove volumes (wipes database)
docker compose down -v
```

**Access Points:**
- Game: http://localhost:3000
- API:  http://localhost:5000/scores
- Health: http://localhost:5000/health

**Verification:**
```bash
# Test health endpoint
curl http://localhost:5000/health

# Get scores (persisted in MongoDB)
curl http://localhost:5000/scores

# Post a test score
curl -X POST http://localhost:5000/scores \
  -H "Content-Type: application/json" \
  -d '{"name":"Player1","score":150}'
```

### ✅ Status: COMPLETED
- ✅ Frontend running on port 3000
- ✅ Backend running on port 5000 with Express API
- ✅ MongoDB running on port 27017
- ✅ MongoDB connection verified via Mongoose
- ✅ Data persistence tested (scores saved and retrieved successfully)

---

## 7. Task 3 — Kubernetes Deployment Steps

Run in **exact order** on Minikube.

### Prerequisites

```bash
# Start Minikube
minikube start

# Point Docker to Minikube's Docker daemon (so local images are available)
eval $(minikube docker-env)
```

### Step 1 — Build images inside Minikube

```bash
docker build -t snake-frontend:latest ./frontend
docker build -t snake-backend:latest ./backend
```

### Step 2 — Apply storage (PV and PVC)

```bash
kubectl apply -f k8s/pv.yaml
kubectl apply -f k8s/pvc.yaml

# Verify
kubectl get pv
kubectl get pvc
```

### Step 3 — Deploy MongoDB

```bash
kubectl apply -f k8s/db-deployment.yaml

# Wait for pod to be ready
kubectl rollout status deployment/db-deployment
```

### Step 4 — Deploy Backend

```bash
kubectl apply -f k8s/backend-deployment.yaml

kubectl rollout status deployment/backend-deployment
```

### Step 5 — Deploy Frontend

```bash
kubectl apply -f k8s/frontend-deployment.yaml

kubectl rollout status deployment/frontend-deployment
```

### Step 6 — Apply HPA

```bash
kubectl apply -f k8s/hpa.yaml
```

### Step 7 — Verify everything

```bash
# Check all pods
kubectl get pods

# Check services
kubectl get services

# Check deployments
kubectl get deployments

# Check HPA
kubectl get hpa
```

### Step 8 — Access the application

```bash
# Get Minikube IP
minikube ip

# Or open directly in browser
minikube service frontend-service
minikube service backend-service
```

URLs (replace `<MINIKUBE-IP>` with output of `minikube ip`):
- Game: `http://<MINIKUBE-IP>:30080`
- API:  `http://<MINIKUBE-IP>:30500/scores`

---

## 8. Task 4 — Persistent Storage

MongoDB data is persisted using a Kubernetes **PersistentVolume** and **PersistentVolumeClaim**.

### How it works

| Resource | File | Purpose |
|----------|------|---------|
| PersistentVolume (PV) | `k8s/pv.yaml` | Reserves 256Mi of storage on the node at `/data/mongo` |
| PersistentVolumeClaim (PVC) | `k8s/pvc.yaml` | Requests 256Mi from the available PVs |
| Volume Mount | `db-deployment.yaml` | Mounts the PVC to `/data/db` inside the MongoDB container |

### Why this matters

Without persistent storage, all score data would be lost whenever the MongoDB pod restarts or is rescheduled. With PV/PVC:

- Data survives pod crashes and restarts
- Data survives `kubectl delete pod` (pod gets recreated and re-attaches to the same volume)
- The volume lives on the host node at `/data/mongo`

### Key settings

```yaml
# pv.yaml
capacity:
  storage: 256Mi
accessModes:
  - ReadWriteOnce   # One node can mount this at a time (correct for MongoDB)
hostPath:
  path: /data/mongo
```

---

## 9. Task 5 — Scaling Configuration

Horizontal Pod Autoscaling (HPA) is configured for both the frontend and backend.

### HPA Summary

| Setting | Backend HPA | Frontend HPA |
|---------|-------------|--------------|
| Target Deployment | `backend-deployment` | `frontend-deployment` |
| Minimum Pods | 2 | 2 |
| Maximum Pods | 5 | 5 |
| Scale-up Trigger | CPU > 70% | CPU > 70% |
| API Version | `autoscaling/v2` | `autoscaling/v2` |

### How it works

1. The HPA continuously monitors CPU utilization across all pods in the target deployment.
2. If average CPU usage exceeds **70%**, Kubernetes adds more pods (up to 5).
3. If CPU drops back down, Kubernetes removes pods (down to the minimum of 2).
4. This ensures the app stays responsive under heavy load without wasting resources at idle.

### Useful commands

```bash
# Watch HPA status live
kubectl get hpa --watch

# Describe HPA for detailed events
kubectl describe hpa backend-hpa
kubectl describe hpa frontend-hpa

# Manually scale a deployment (override HPA temporarily)
kubectl scale deployment backend-deployment --replicas=4
```

### Enabling HPA metrics (required for autoscaling to work)

```bash
# Enable metrics-server addon in Minikube
minikube addons enable metrics-server

# Verify metrics are flowing
kubectl top pods
kubectl top nodes
```

---

## 11. Troubleshooting & Known Issues

### Issue 1: Docker Compose — "unable to get image 'mongo:6-jammy'"

**Problem:**
```
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.51/images/mongo:6-jammy/json": 
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

**Cause:** MongoDB image is not pre-downloaded. Docker tries to pull it during `docker compose up`, and this can fail or timeout.

**Solution:**
```bash
# Pre-pull the MongoDB image before running compose
docker pull mongo:6-jammy

# Then run docker compose
docker compose up -d
```

### Issue 2: Docker Compose Version Warning

**Warning:**
```
time="2026-03-15T09:04:48+05:00" level=warning msg="F:\\Semester8\\Devops_Assign_2\\snake-game\\docker-compose.yml: 
the attribute `version` is obsolete, it will be ignored, please remove it to avoid potential confusion"
```

**Cause:** Docker Compose v2 has deprecated the `version` attribute in `docker-compose.yml`.

**Solution (Optional):** Remove line 1 from `docker-compose.yml`:
```diff
- version: "3.8"
-
  services:
```

**Impact:** ⚠️ **Not critical** — the application runs fine with this warning.

### Issue 3: Backend Logs Not Showing MongoDB Connection Message

**Observation:** Running `docker logs snake-backend` only shows `[API] Snake Game backend running on port 5000` but no MongoDB connection success message.

**Cause:** This is normal behavior when backend connects to MongoDB through docker-compose networking. The connection actually succeeds silently.

**Verification:** Test the API to confirm MongoDB is working:
```bash
# Test GET /scores (requires MongoDB)
curl http://localhost:5000/scores
# Returns: []

# Test POST /scores (persists to MongoDB)
curl -X POST http://localhost:5000/scores \
  -H "Content-Type: application/json" \
  -d '{"name":"Player1","score":150}'
# Returns: {"message":"Score saved.","data":{...}}

# Test GET /scores again (confirms persistence)
curl http://localhost:5000/scores
# Returns: [{"_id":"...", "name":"Player1", "score":150, ...}]
```

### Issue 4: MongoDB Connection String Changes Between Environments

**Docker Compose (working):**
```
mongodb://db:27017/snakegame
```
Uses service name `db` for hostname within the containerized network.

**Docker Individual Containers (backend only, requires fix):**
```
-e MONGO_URI=mongodb://host.docker.internal:27017/snakegame
```
Backend must use `host.docker.internal` to reach MongoDB on the host (Windows/Mac Docker Desktop).

**Kubernetes (will use):**
```
mongodb://db-service:27017/snakegame
```
Uses Kubernetes Service DNS name `db-service`.

### Issue 5: Port Conflicts

If you get "port already allocated" error:

```bash
# Find what's using the port
netstat -ano | findstr :5000

# Kill the process (replace PID)
taskkill /PID <PID> /F

# OR change the port in docker-compose.yml
```

---

## 12. Current Completion Status

### ✅ TASK 2 — Docker Compose Setup: COMPLETED

**What works:**
- ✅ All three containers running (frontend, backend, db)
- ✅ Frontend accessible at http://localhost:3000
- ✅ Backend API responding at http://localhost:5000
- ✅ MongoDB successfully connected via Mongoose
- ✅ Data persistence verified (scores saved and retrieved)
- ✅ Health check endpoint working: GET /health → {status: "ok"}
- ✅ Scores API working: GET/POST /scores

**Tested endpoints:**
```bash
✅ GET  http://localhost:5000/health        → {"status":"ok","timestamp":"..."}
✅ GET  http://localhost:5000/scores        → [{"_id":"...","name":"Player1","score":150,...}]
✅ POST http://localhost:5000/scores        → {"message":"Score saved.","data":{...}}
✅ GET  http://localhost:3000               → Frontend HTML (Status 200)
```

### ⏳ TODO — Remaining Tasks

1. **Task 1** — Docker Individual Build & Run (not attempted)
2. **Task 3** — Kubernetes Deployment (not attempted)
3. **Task 4** — Persistent Storage (will use with K8s)
4. **Task 5** — HPA Scaling (will configure in K8s)

---

*Last Updated: March 15, 2026*

## 13. Screenshots & Test Results

Capture the following screenshots for your submission.

### Task 1 — Docker Containers

```bash
docker ps
```
Screenshot: All three containers running (snake-frontend, snake-backend, snake-db) with their ports.

```bash
# Also screenshot the game open in your browser at http://localhost:3000
```

### Task 2 — Docker Compose ✅ COMPLETED

**Completed on: March 15, 2026**

```bash
# Start services
docker pull mongo:6-jammy
docker compose up -d
docker compose ps
```

**Screenshots needed:**
1. Terminal showing `docker compose ps` with all three services in `Up` state
2. Terminal showing successful health check:
   ```bash
   curl http://localhost:5000/health
   # Expected: {"status":"ok","timestamp":"..."}
   ```
3. Terminal showing database connectivity:
   ```bash
   curl http://localhost:5000/scores
   # Expected: []
   ```
4. Terminal showing data persistence:
   ```bash
   # POST a test score
   curl -X POST http://localhost:5000/scores \
     -H "Content-Type: application/json" \
     -d '{"name":"Player1","score":150}'
   # Expected: {"message":"Score saved.","data":{...}}
   
   # GET scores (verify persistence)
   curl http://localhost:5000/scores
   # Expected: [{"_id":"...","name":"Player1","score":150,...}]
   ```
5. Browser screenshot showing the game at http://localhost:3000
docker compose up -d
docker compose ps
```
Screenshot: All three services in `Up` state from `docker compose ps`.

### Task 3 — Kubernetes Pods

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```
Screenshot: All pods in `Running` state with 3 replicas each for frontend and backend.

### Task 4 — Persistent Storage

```bash
kubectl get pv
kubectl get pvc
```
Screenshot: PV and PVC both in `Bound` state.

### Task 5 — Scaling / HPA

```bash
kubectl get hpa
kubectl describe hpa backend-hpa
kubectl describe hpa frontend-hpa
```
Screenshot: Both HPAs showing min/max replicas and CPU target.

---

*Assignment 2 — Docker & Kubernetes | Snake Game Application*
