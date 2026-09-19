Kubernetes Local Deployments and Basic Observability

Project overview

This project deploys an Incident Management Portal to a local three-node Kind cluster. It demonstrates multi-tier Kubernetes workloads, persistent database storage, configuration management, workload scheduling, ingress routing, health checks, and basic monitoring with Prometheus and Grafana.

Outcome

The completed platform provides:

A three-node Kind cluster named dev-cluster.

A two-tier application slice consisting of the backend API and PostgreSQL.

A complete three-tier application consisting of the frontend, backend API, and PostgreSQL.

ClusterIP Services for internal communication.

NGINX Ingress for external application routing.

ConfigMaps and Secrets for application configuration.

A PostgreSQL StatefulSet with a 2 Gi persistent volume claim.

Readiness, liveness, and startup probes.

Taints, tolerations, labels, and node selectors for workload placement.

Prometheus metrics collection and a provisioned Grafana dashboard.

Architecture

flowchart TD
    Client[Browser] --> Ingress[NGINX Ingress]
    Ingress --> Frontend[Frontend Service]
    Frontend --> Backend[Backend Service]
    Backend --> Database[(PostgreSQL and PVC)]
    Prometheus -->|Scrape /metrics| Backend
    Grafana --> Prometheus

Application flow

The browser sends traffic to the NGINX Ingress Controller.

The Ingress resource routes requests to the frontend Service.

The frontend NGINX container serves the user interface and proxies /api requests to the backend Service.

The backend connects to PostgreSQL through the headless PostgreSQL Service.

Prometheus scrapes the backend /metrics endpoint.

Grafana uses Prometheus as its automatically provisioned data source.

Project structure

kubernetes/
├── kind-config.yaml
├── namespace.yaml
├── postgres.yaml
├── backend.yaml
├── frontend.yaml
├── ingress.yaml
├── kustomization.yaml
├── TROUBLESHOOTING.md
└── monitoring/
    ├── namespace.yaml
    ├── prometheus.yaml
    ├── grafana.yaml
    └── kustomization.yaml

Kubernetes resources

Component

Workload

Service

Important configuration

Frontend

Deployment

ClusterIP on port 80

NGINX ConfigMap and health probes

Backend

Deployment

ClusterIP on port 5000

Database Secret, init container, and health probes

PostgreSQL

StatefulSet

Headless Service on port 5432

Initialization ConfigMap and 2 Gi PVC

Prometheus

Deployment

ClusterIP on port 9090

Backend /metrics scrape configuration

Grafana

Deployment

ClusterIP on port 3000

Provisioned data source and dashboard

Prerequisites

Docker

Kind

kubectl

Helm 3

Vagrant and VirtualBox for the local Ubuntu environment

Create the cluster

kind create cluster --name dev-cluster --config kind-config.yaml

Confirm the nodes:

kubectl get nodes

Load the application images

Build the application images from the application repository, then load them into Kind. The image names must match the image fields in frontend.yaml and backend.yaml.

docker compose build frontend backend

kind load docker-image \
  incident-management-portal-frontend:latest \
  incident-management-portal-backend:latest \
  --name dev-cluster

Configure workload placement

PostgreSQL is reserved for a dedicated worker using a label, taint, node selector, and toleration:

kubectl label node dev-cluster-worker workload=database --overwrite
kubectl taint node dev-cluster-worker dedicated=database:NoSchedule --overwrite

The monitoring workloads run on the other worker:

kubectl label node dev-cluster-worker2 workload=monitoring --overwrite

The PostgreSQL StatefulSet contains:

nodeSelector:
  workload: database

tolerations:
  - key: dedicated
    operator: Equal
    value: database
    effect: NoSchedule

Prometheus and Grafana contain:

nodeSelector:
  workload: monitoring

A toleration permits PostgreSQL to use the tainted node, while the node selector requires it to use the node labelled workload=database.

Deploy the application

Do not commit real passwords. Replace placeholder values in local Secret manifests before applying them.

kubectl apply -k .

Verify the application and storage:

kubectl get pods,svc,pvc -n incident-portal -o wide

The expected result is that the frontend, backend, and PostgreSQL pods are Running, while postgres-data is Bound.

Install the NGINX Ingress Controller

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=ClusterIP

Verify the controller and IngressClass:

kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx
kubectl get ingressclass
kubectl get ingress -n incident-portal

The application Ingress sends / traffic to the frontend Service. The frontend then proxies /api traffic to the backend.

Deploy Prometheus and Grafana

The monitoring deployment is intentionally lightweight to suit the local VM. Prometheus scrapes:

backend.incident-portal.svc.cluster.local:5000/metrics

Apply the monitoring manifests:

kubectl apply -k monitoring/
kubectl get pods,svc -n monitoring -o wide

The provisioned Grafana dashboard contains:

Backend availability.

Backend resident memory.

Backend CPU usage.

Backend uptime.

Access from Windows

VirtualBox NAT prevents the Windows browser from directly using the VM's 10.0.2.15 address. Keep these port-forward commands running inside Vagrant:

kubectl port-forward -n ingress-nginx \
  svc/ingress-nginx-controller 8080:80 --address 127.0.0.1

kubectl port-forward -n monitoring \
  svc/prometheus 9091:9090 --address 127.0.0.1

kubectl port-forward -n monitoring \
  svc/grafana 3001:3000 --address 127.0.0.1

From Windows PowerShell in the directory containing the Vagrantfile, open an SSH tunnel:

vagrant ssh -- `
  -L 18080:127.0.0.1:8080 `
  -L 19091:127.0.0.1:9091 `
  -L 13001:127.0.0.1:3001

Keep the tunnel running and open:

Resource

URL

Incident Portal through Ingress

http://localhost:18080

Prometheus targets

http://localhost:19091/targets

Grafana

http://localhost:13001

Validation

Check the complete deployment:

kubectl get nodes -L workload
kubectl get pods,svc,pvc,ingress -n incident-portal -o wide
kubectl get pods,svc -n monitoring -o wide
kubectl get ingressclass

Test the database health endpoint through Ingress:

curl http://127.0.0.1:8080/api/health/db

Expected response:

{"status":"ok","database":"connected"}

Confirm the Prometheus backend target is UP at the Prometheus targets page. Open the provisioned Incident Portal - Basic Observability dashboard in Grafana and confirm that it displays data.

Persistent storage test

Create a ticket in the portal.

Delete the PostgreSQL pod:

kubectl delete pod postgres-0 -n incident-portal

Wait for the StatefulSet to recreate the pod:

kubectl rollout status statefulset/postgres -n incident-portal

Refresh the portal and confirm that the ticket remains available.

The StatefulSet recreates the pod while the PVC preserves the PostgreSQL data. Deleting the PVC or the entire Kind cluster can remove the local data.

Evidence checklist

Kind nodes in Ready state.

Application pods, Services, StatefulSet, and bound PVC.

Database node label and taint.

Monitoring node label and monitoring pod placement.

NGINX IngressClass and Ingress resource.

Application loaded through the Ingress Controller.

Database health response showing connected.

Prometheus targets showing UP.

Grafana dashboard displaying backend metrics.

Ticket retained after PostgreSQL pod recreation.

Production improvements

Pin immutable image versions instead of using latest.

Store secrets outside Git using a secret-management solution.

Add TLS to the Ingress.

Use persistent storage for Prometheus if long-term metrics retention is required.

Configure monitoring alerts and notification routes.

Add NetworkPolicies and Kubernetes RBAC.

Build and publish images through CI/CD rather than loading them manually.

Result

This project demonstrates the ability to deploy and troubleshoot a stateful, multi-tier Kubernetes application locally, control workload placement, route traffic through Ingress, preserve database data, and add foundational Prometheus and Grafana observability.