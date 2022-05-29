gcloud config set compute/zone us-central1-a

# create a default cluster
gcloud container clusters create [CLUSTER-NAME]

# get credentials for kubectl
gcloud container clusters get-credentials [CLUSTER-NAME]

# create a deployment imperatively
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0

# create a service imperatively, using a deployment
kubectl expose deployment hello-server --type=LoadBalancer --port 8080

# see services
kubectl get service

# delete a cluster
gcloud container clusters delete [CLUSTER-NAME]
