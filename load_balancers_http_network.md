# SETUP NETWORK LOAD BALANCER
https://cloud.google.com/load-balancing/docs/network

# set config
gcloud config set compute/zone us-central1-a

gcloud config set compute/region us-central1

# create three VM instances
gcloud compute instances create www1 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www1</h1></body></html>' | tee /var/www/html/index.html"

gcloud compute instances create www2 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www2</h1></body></html>' | tee /var/www/html/index.html"

gcloud compute instances create www3 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www3</h1></body></html>' | tee /var/www/html/index.html"

# create firewall rules
gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag --allow tcp:80

# create an IP
gcloud compute addresses create network-lb-ip-1 \
 --region us-central1

# create an HTTP health checks
gcloud compute http-health-checks create basic-check

# create a target pool with HTTP health check
gcloud compute target-pools create www-pool \
    --region us-central1 --http-health-check basic-check

# add instances to the pool
gcloud compute target-pools add-instances www-pool \
    --instances www1,www2,www3

# add forwarding rule to the pool
gcloud compute forwarding-rules create www-rule \
    --region us-central1 \
    --ports 80 \
    --address network-lb-ip-1 \
    --target-pool www-pool

* whenever a traffic comes to port 80 of address network-lb-ip-1, it is forwarded to the pool. the pool will forward the traffic to one of the instance

# SETUP HTTP LOAD BALANCER

load balancer sends traffic to the backend instance group where VMs waiting to serve the request

# create load balancer template (for the backend instance group)
gcloud compute instance-templates create lb-backend-template \
   --region=us-central1 \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --image-family=debian-9 \
   --image-project=debian-cloud \
   --metadata=startup-script='#! /bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     vm_hostname="$(curl -H "Metadata-Flavor:Google" \
     http://169.254.169.254/computeMetadata/v1/instance/name)"
     echo "Page served from: $vm_hostname" | \
     tee /var/www/html/index.html
     systemctl restart apache2'

# create a managed instance group based on the template
gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template --size=2 --zone=us-central1-a

# create a firewall rule to allow health-check
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80

# create a static ip for the load balancer
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global

# see the address
gcloud compute addresses describe lb-ipv4-1 \
    --format="get(address)" \
    --global

# create health-check (it is not the legacy http-health-checks)
gcloud compute health-checks create http http-basic-check \
    --port 80

# create backend service
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

# add instance group to backend service
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --instance-group-zone=us-central1-a \
    --global

# create url-maps
--> route incoming request to `default backend service`
--> set the `default-service` with url-maps
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

# create a target http proxy to route requests to URL map
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

# create forwarding rule to route request to the proxy
--> any request comes to port 80 of address lb-ipv4-1 will be forwarded to http-lb-proxy, which will forward to backend services using url-map

gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
