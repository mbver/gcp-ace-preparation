# set zone
gcloud config set compute/zone us-central1-a

# copy source
gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .
cd orchestrate-with-kubernetes/kubernetes

# create a cluster of 5 nodes
gcloud container clusters create bootcamp --num-nodes 5 --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

# see parameters of deployment
kubectl explain deployment

kubectl explain deployment --recursive

kubectl explain deployment.metadata.name

# deploy auth
kubectl create -f deployments/auth.yaml

# check
kubectl get deployments
kubectl get replicasets
kubectl get pods

# create service for auth
kubectl create -f services/auth.yaml

# create deployment and service for hello
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

# create and expose frontend
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

# check
kubectl get services frontend
curl -ks https://<EXTERNAL-IP>

curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`

# see meaning of replicas
kubectl explain deployment.spec.replicas

# scale
kubectl scale deployment hello --replicas=5

# check number of pods
kubectl get pods | grep hello- | wc -l

# scale down
kubectl scale deployment hello --replicas=3

# rolling update
kubectl edit deployment hello

# check
kubectl get replicaset
kubectl rollout history deployment/hello

# pause rolling update
kubectl rollout pause deployment/hello

# check status
kubectl rollout status deployment/hello

kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
 
# resume rolling update
kubectl rollout resume deployment/hello

# rollback
kubectl rollout undo deployment/hello

# check
kubectl rollout history deployment/hello
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# canary deployment
kubectl create -f deployments/hello-canary.yaml

# check
kubectl get deployments

curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version

# blue deployment (just update the service)
kubectl apply -f services/hello-blue.yaml

# create green deployment
kubectl create -f deployments/hello-green.yaml

# deploy green service
kubectl apply -f services/hello-green.yaml

# rollback to blue
kubectl apply -f services/hello-blue.yaml
