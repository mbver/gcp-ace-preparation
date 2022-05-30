Configuring Persistent Storage for Google Kubernetes Engine

# Objectives
- Create manifests for PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs) for Google Cloud persistent disks (dynamically created or existing)
- Mount Google Cloud persistent disk PVCs as volumes in Pods
- Use manifests to create StatefulSets
- Mount Google Cloud persistent disk PVCs as volumes in StatefulSets
- Verify the connection of Pods in StatefulSets to particular PVs as the Pods are stopped and restarted

# set up ENV (see creating_gke_deployment.md)

# pvc-demo.yaml
Most of the time, you don't need to directly configure PV objects or create Compute Engine persistent disks.
- Instead, you can create a PVC, and Kubernetes automatically provisions a persistent disk for you.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: hello-web-disk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi
```
# create PVC
kubectl apply -f pvc-demo.yaml

# check PVC
kubectl get persistentvolumeclaim

# clone source (see creating_gke_deployment)

# pod-volume-demo.yaml
- deploys an nginx container
- attaches the pvc-demo-volume to the Pod
- mounts that volume to the path /var/www/html inside the nginx container. 

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: pvc-demo-pod
spec:
  containers:
    - name: frontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: pvc-demo-volume
  volumes:
    - name: pvc-demo-volume
      persistentVolumeClaim:
        claimName: hello-web-disk
```
# deploy Pod
kubectl apply -f pod-volume-demo.yaml

# check Pods
kubectl get pods

# access the Pod
kubectl exec -it pvc-demo-pod -- sh

# delete the Pod
kubectl delete pod pvc-demo-pod

# re-deploy the Pod
kubectl apply -f pod-volume-demo.yaml

# access the Pod and check if data persists
kubectl exec -it pvc-demo-pod -- sh

# delete Pod to release the PVC to use it in StatefulSets
kubectl delete pod pvc-demo-pod

