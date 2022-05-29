Creating Google Kubernetes Engine Deployments

# setup cloud shell env
export my_zone=us-central1-a
export my_cluster=standard-cluster-1
source <(kubectl completion bash)

# get credentials
gcloud container clusters get-credentials $my_cluster --zone $my_zone

# clone source
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
cd ~/ak8s/Deployments/

# nginx-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```
# deploy
kubectl apply -f ./nginx-deployment.yaml

# check deployment
kubectl get deployments

# scale down in console manually
- Switch to the Google Cloud Console tab.
- On the Navigation menu, click Kubernetes Engine > Workloads.
- Click nginx-deployment (your deployment) to open the Deployment details page.
- At the top, click ACTIONS > Scale.
- Type 1 and click SCALE.

# scale up with cloud shell command
kubectl scale --replicas=3 deployment nginx-deployment

# trigger a deployment rollout
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1 --record

# check rollout status
kubectl rollout status deployment.v1.apps/nginx-deployment

# view rollout history
kubectl rollout history deployment nginx-deployment

# rollback a rollout
kubectl rollout undo deployments nginx-deployment

# view rollout history
kubectl rollout history deployment nginx-deployment

# view details of latest rollout
kubectl rollout history deployment/nginx-deployment --revision=3

# service-nginx.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 60000
    targetPort: 80
```
kubectl apply -f ./service-nginx.yaml

# check service
kubectl get service nginx

# nginx-canary.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-canary
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        track: canary
        Version: 1.9.1
    spec:
      containers:
      - name: nginx
        image: nginx:1.9.1
        ports:
        - containerPort: 80
```
# deploy the canary deployment
kubectl apply -f nginx-canary.yaml

# check deployments
kubectl get deployments

# scale down the primary deployment
kubectl scale --replicas=0 deployment nginx-deployment

# Session affinity
set the sessionAffinity field to ClientIP in the specification of the service if you need a client's first request to determine which Pod will be used for all subsequent connections.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  type: LoadBalancer
  sessionAffinity: ClientIP
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 60000
    targetPort: 80
```