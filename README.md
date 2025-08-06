# NAGP Kube DevOps Demo – Django + MySQL

A Service API is exposed using Django + MySQL, containerized with Docker, orchestrated with Docker Compose, and production-ready for Kubernetes (local or GCP).

---
## Requirement Understanding
The application consists of two tiers:

### Service API Tier: 
- Built using Python and Django, requires external exposure, runs multiple pods, and supports rolling updates.

### Database Tier: 
- Uses MySQL, needs persistent storage, does not support rolling updates, and should be securely configured.

----
## Solution Overview
- Service API Tier is deployed using a Deployment with 4 replicas.

- It is exposed externally via Ingress, with a Service (ClusterIP) handling internal routing.

- MySQL is deployed using a StatefulSet with a PersistentVolumeClaim for durable storage.

- ConfigMap stores database configuration (e.g., DB_HOST, DB_USER).

- Secret securely stores the DB password.

- Pod-to-pod communication is handled using Kubernetes Services, not raw IPs.

----
## Assumptions
- The Django app uses environment variables for DB config (e.g., host, user, password).

- Kubernetes cluster supports Ingress (e.g., NGINX Ingress Controller).

- PersistentVolume and PersistentVolumeClaim are available for MySQL storage.

- Secrets and ConfigMaps are supported and accessible by the pods.

----
## Justification for the Resources Utilized
- Deployment for API Tier: Supports rolling updates and scaling.

- StatefulSet for MySQL: Ensures stable identity and persistent volume usage.

- ConfigMap: Allows environment-specific DB settings without changing code.

- Secret: Enhances security by avoiding plain-text credentials.

- Ingress: Provides a clean and manageable external entry point.

----

## Steps followed Locally with Docker Compose

## Create a `.env` file in the root:

`SQL_ENGINE=django.db.backends.mysql`  
`SQL_DATABASE=nagpdb`  
`SQL_USER=nagp_admin ` 
`SQL_PASSWORD=nagp2025`  
`SQL_ROOT_PASSWORD=root`  
`SQL_HOST=mysql_db`  
`SQL_PORT=3306`  
`DJANGO_SECRET_KEY=your-secret-key ` 
`DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 ` 

## Local machine excecution 

`python manage.py migrate`

`python manage.py loaddata products.json`

`python manage.py runserver`

## Build and run:

`docker build -t nagp-py-app .`

`docker run -p 8000:8000 nagp-py-app`

`docker tag nagp-py-app bootloader720/nagp-py-app:latest`

`docker push bootloader720/nagp-py-app:latest`

-----------------------------------------------

## Docker compose 

`docker-compose up --build`

`docker-compose exec web python manage.py migrate`

`docker-compose exec web python manage.py loaddata products.json`


## Local testing 

`http://127.0.0.1:8000/api/products/`


---
## Set Up the GCP Project and GKE Cluster

`gcloud auth login`

## Set your project ID

`gcloud config set project <gcp-project-id>`

## Image Build & Push for GCP:

`docker build -t gcr.io/<gcp-project-id>/nagp-py-app:latest .`

`docker push gcr.io/<gcp-project-id>/nagp-py-app:latest`

## Create a Persistent Disk 
Create a Persistent Disk that can later be used in GKE 

`gcloud compute disks create gke-mysql-disk --size=1GB --zone=us-central1-a`

## Deploy to Kubernetes (GCP)

1. Apply config and secrets:

   `kubectl apply -f k8s/mysql-secret.yaml ` 

   `kubectl apply -f k8s/mysql-configmap.yaml` 

2. Apply Persistent Voulme  and PVC 
   `kubectl apply -f mysql-pv.yaml`
   `kubectl apply -f mysql-pvc.yaml`

3. Deploy MySQL:
	`kubectl apply -f k8s/mysql-deployment.yaml`
	`kubectl apply -f k8s/mysql-service.yaml`   

4. Update `web-deployment.yaml` image field to your pushed image:

   image: `gcr.io/YOUR_PROJECT_ID/nagp-py-app:latest`

   Then deploy Django app:

`kubectl apply -f k8s/django-deployment.yaml`  

5. Deploy Ingress:

`kubectl apply -f k8s/ingress.yaml`  

To test locally, update `/etc/hosts`:

`<ingress-external-ip> nagp.local`  

Then visit: http://nagp.local:8000/api/products/


---

## Database Init Options

To load data automatically:
- Use init.sql via ConfigMap and mount at `/docker-entrypoint-initdb.d/init.sql`

Or manually:

kubectl cp Dump20250805.sql mysql-d8468b4df-mzsj4:/tmp/dump.sql

kubectl exec -it mysql-<pod-id> -- bash

mysql -u nagp_admin -p nagpdb < /tmp/dump.sql

---

## Test API:

curl http://<web-ip-address>:8000/api/products/

Expected:

[
  {"name": "Rocket Kit", "description": "Toy rocket", "price": "199.99"},
  ...
]

---

## Stack:

- Python 3.11
- Django 5.x
- MySQL 8.0
- Docker / Docker Compose
- Kubernetes
- GCP