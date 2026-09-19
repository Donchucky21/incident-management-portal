Kubernetes Troubleshooting Notes

These notes record the main problems encountered while deploying the Incident Management Portal to the local Kind cluster and the steps used to diagnose and resolve them.

1. Backend pod was running but not ready

Symptoms

backend-...   0/1   Running

The backend process started, but the readiness probe did not pass.

Diagnosis

kubectl logs -n incident-portal deployment/backend --tail=100
kubectl describe pod -n incident-portal <backend-pod-name>

The pod events showed that the readiness probe received HTTP 404 from /api/health/db. The running Kind pod was using an older backend image that did not contain the database health endpoint.

Resolution

The backend was rebuilt, loaded into Kind, and restarted:

docker compose build --no-cache backend
kind load docker-image incident-management-portal-backend:latest --name dev-cluster
kubectl rollout restart deployment/backend -n incident-portal
kubectl rollout status deployment/backend -n incident-portal

The health endpoint was then checked directly:

kubectl exec -n incident-portal deployment/backend -- \
  wget -qO- http://127.0.0.1:5000/api/health/db

2. Backend attempted to use SSL with local PostgreSQL

Symptom

Database initialization failed: The server does not support SSL connections

Cause

The database client always enabled SSL. This was appropriate for the previous AWS RDS environment but not for the local PostgreSQL container in Kind.

Disabling certificate verification with rejectUnauthorized: false still enables SSL; it only stops certificate validation.

Resolution

The database configuration was made environment-aware:

ssl:
  process.env.DB_SSL === "true"
    ? { rejectUnauthorized: false }
    : false,

The Kubernetes backend Deployment provides:

- name: DB_SSL
  value: "false"

For an RDS environment, DB_SSL can be set to true.

After rebuilding and loading the corrected image, the endpoint returned:

{"status":"ok","database":"connected"}

3. PostgreSQL scheduling with taints and tolerations

Objective

PostgreSQL needed to run on a dedicated Kind worker as a scheduling exercise.

Configuration

The node was labelled and tainted:

kubectl label node dev-cluster-worker workload=database --overwrite
kubectl taint node dev-cluster-worker dedicated=database:NoSchedule --overwrite

The StatefulSet uses both a node selector and toleration:

nodeSelector:
  workload: database

tolerations:
  - key: dedicated
    operator: Equal
    value: database
    effect: NoSchedule

The node selector forces the pod onto the labelled node. The toleration only permits the pod to be scheduled despite the taint.

Verification

kubectl get pod postgres-0 -n incident-portal -o wide
kubectl get node dev-cluster-worker -o jsonpath='{.spec.taints}{"\n"}'
kubectl get nodes -L workload

A temporary pod without the database toleration remained Pending, confirming that the taint was effective.

Storage consideration

Kind's local persistent volume can be tied to the node where it was created. Moving PostgreSQL to another node may produce a volume node-affinity conflict. The existing database node was retained to preserve access to the PVC.

4. Image loading failed with no space left on device

Symptom

failed to extract layer: no space left on device

Cause

kind load docker-image copies an image into every Kind node. Loading large Grafana and Prometheus images into all three nodes duplicated their layers and exhausted the Vagrant VM's disk during extraction.

Diagnosis

df -h /
docker system df
docker exec dev-cluster-worker df -h

Resolution

Only safe unused cache was removed:

docker image prune -f
docker builder prune -f

The monitoring worker was identified and labelled:

kubectl label node dev-cluster-worker2 workload=monitoring --overwrite

Prometheus was imported only into that node:

docker save prom/prometheus:latest | \
  docker exec --privileged -i dev-cluster-worker2 \
  ctr --namespace=k8s.io images import -

The result was verified:

docker exec dev-cluster-worker2 crictl images | grep prometheus

Prometheus and Grafana use nodeSelector: workload: monitoring, so Kubernetes schedules them on the node containing the required images.

docker system prune -a and volume deletion were avoided because they could remove local application images or database data.

5. Prometheus and Grafana were not reachable from Windows

Symptom

Opening http://localhost:9091 from Windows returned ERR_CONNECTION_REFUSED.

Cause

The Kubernetes port forward existed inside the Vagrant VM. In the Windows browser, localhost refers to Windows, not the VM. The VM address 10.0.2.15 was also not directly reachable because it belonged to the VirtualBox NAT network.

Resolution

The Kubernetes Service was first forwarded to the Vagrant loopback interface:

kubectl port-forward -n monitoring \
  svc/prometheus 9091:9090 --address 127.0.0.1

Prometheus was tested from inside Vagrant:

curl http://127.0.0.1:9091/-/ready

An SSH tunnel was then opened from Windows:

vagrant ssh -- -L 19091:127.0.0.1:9091

Prometheus became available at http://localhost:19091/targets.

Grafana used the same two-stage approach:

kubectl port-forward -n monitoring \
  svc/grafana 3001:3000 --address 127.0.0.1

vagrant ssh -- -L 13001:127.0.0.1:3001

Grafana became available at http://localhost:13001.

6. Testing application traffic through Ingress

The NGINX Ingress Controller was installed with Helm as a ClusterIP Service. The application Ingress routes traffic to the frontend Service, which proxies /api traffic to the backend.

The controller was exposed temporarily inside Vagrant:

kubectl port-forward -n ingress-nginx \
  svc/ingress-nginx-controller 8080:80 --address 127.0.0.1

An SSH tunnel exposed it to Windows:

vagrant ssh -- -L 18080:127.0.0.1:8080

The portal was successfully opened at http://localhost:18080.

The full application path was verified with:

curl http://127.0.0.1:8080/api/health/db

Successful response:

{"status":"ok","database":"connected"}

This confirmed the complete route:

Ingress Controller → frontend Service → frontend pod → backend Service → backend pod → PostgreSQL

7. PostgreSQL PVC verification

Verification

kubectl get pvc -n incident-portal

The postgres-data PVC showed Bound with a capacity of 2 Gi and ReadWriteOnce access.

Pod recreation test

kubectl delete pod postgres-0 -n incident-portal
kubectl rollout status statefulset/postgres -n incident-portal

The StatefulSet recreated postgres-0 and reused the PVC. Existing tickets remained available because the data was stored outside the pod filesystem.

Deleting the PVC or the entire Kind cluster can delete the locally stored data.

Useful diagnostic commands

kubectl get pods -A -o wide
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
kubectl logs deployment/<deployment-name> -n <namespace>
kubectl get events -n <namespace> --sort-by=.metadata.creationTimestamp
kubectl get svc,endpoints -n <namespace>
kubectl get ingress,ingressclass -A
kubectl get pvc,pv
kubectl top pods -A

For a pod with an init container, select the application container explicitly when required:

kubectl logs <pod-name> -n <namespace> -c <container-name>

Troubleshooting approach used

Check the resource status with kubectl get.

Inspect events with kubectl describe.

Read application and container logs.

Test health endpoints inside the pod or VM.

Confirm Service selectors and endpoints.

Confirm image versions and environment variables.

Apply the smallest correction.

Restart or roll out the workload and verify the complete traffic path.
