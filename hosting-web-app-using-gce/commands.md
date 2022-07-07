# set zone
gcloud config set compute/zone us-central1-f

# enable gce service
gcloud services enable compute.googleapis.com

# create a gs bucket
gsutil mb gs://fancy-store-$DEVSHELL_PROJECT_ID

# clone source
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices

# run initial build of code
./setup.sh
nvm install --lts

# run the app locally
cd microservices
npm start

----------------------------------------------

# CREATE GCE INSTANCES

# create startup script
~/monolith-to-microservices/startup-script.sh
```sh
#!/bin/bash
# Install logging monitor. The monitor will automatically pick up logs sent to
# syslog.
curl -s "https://storage.googleapis.com/signals-agents/logging/google-fluentd-install.sh" | bash
service google-fluentd restart &
# Install dependencies from apt
apt-get update
apt-get install -yq ca-certificates git build-essential supervisor psmisc
# Install nodejs
mkdir /opt/nodejs
curl https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-x64.tar.gz | tar xvzf - -C /opt/nodejs --strip-components=1
ln -s /opt/nodejs/bin/node /usr/bin/node
ln -s /opt/nodejs/bin/npm /usr/bin/npm
# Get the application source code from the Google Cloud Storage bucket.
mkdir /fancy-store
gsutil -m cp -r gs://fancy-store-[DEVSHELL_PROJECT_ID]/monolith-to-microservices/microservices/* /fancy-store/
# Install app dependencies.
cd /fancy-store/
npm install
# Create a nodeapp user. The application will run as this user.
useradd -m -d /home/nodeapp nodeapp
chown -R nodeapp:nodeapp /opt/app
# Configure supervisor to run the node app.
cat >/etc/supervisor/conf.d/node-app.conf << EOF
[program:nodeapp]
directory=/fancy-store
command=npm start
autostart=true
autorestart=true
user=nodeapp
environment=HOME="/home/nodeapp",USER="nodeapp",NODE_ENV="production"
stdout_logfile=syslog
stderr_logfile=syslog
EOF
supervisorctl reread
supervisorctl update
```

replace DEVSHELL_PROJECT_ID with your project's ID

# push the script to GS bucket
gsutil cp ~/monolith-to-microservices/startup-script.sh gs://fancy-store-$DEVSHELL_PROJECT_ID

# copy code to cloud storage bucket
cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

------------------------------------------------

# deploy backend instance
gcloud compute instances create backend \
    --machine-type=n1-standard-1 \
    --tags=backend \
   --metadata=startup-script-url=https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh

----------------------------------------

# configure connection to backend

# get the external ip of instance
gcloud compute instances list
watch -n 2 gcloud compute operations list \
--filter='operationType~compute.instances.repair.*'
# change .env file in monolithic-to-microservices/react-app
-> replace localhost with instance external address

# build react app
cd ~/monolith-to-microservices/react-app
npm install && npm run-script build

# push the code to cloud storage
cd ~
rm -rf monolith-to-microservices/*/node_modules

gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

* -m cause supported operations run in parallel => boost performance

--------------------------------------

# deploy frontend instance
gcloud compute instances create frontend \
    --machine-type=n1-standard-1 \
    --tags=frontend \
    --metadata=startup-script-url=https://storage.googleapis.com/fancy-store-$DEVSHELL_PROJECT_ID/startup-script.sh

-------------------------------------

# configure network
gcloud compute firewall-rules create fw-fe \
    --allow tcp:8080 \
    --target-tags=frontend

gcloud compute firewall-rules create fw-be \
    --allow tcp:8081-8082 \
    --target-tags=backend

---------------------------------------

# monitor watch -n 2 gcloud compute operations list \
--filter='operationType~compute.instances.repair.*'ANAGED INSTANCE GROUPS

# stop both instances

gcloud compute instances stop frontend

gcloud compute instances stop backend

# create instance templates from instances
gcloud compute instance-templates create fancy-fe \
    --source-instance=frontend

gcloud compute instance-templates create fancy-be \
    --source-instance=backend

# confirm the templates were created
gcloud compute instance-templates list

# delete backend instance to save resource
gcloud compute instances delete backend

# create managed instance groups
gcloud compute instance-groups managed create fancy-fe-mig \
    --base-instance-name fancy-fe \
    --size 2 \
    --template fancy-fe

gcloud compute instance-groups managed create fancy-be-mig \
    --base-instance-name fancy-be \
    --size 2 \
    --template fancy-be

# create named ports for services in managed instance groups
gcloud compute instance-groups set-named-ports fancy-fe-mig \
    --named-ports frontend:8080

gcloud compute instance-groups set-named-ports fancy-be-mig \
    --named-ports orders:8081,products:8082

-------------------------------------------

# configure autohealing

# create health checks
gcloud compute health-checks create http fancy-fe-hc \
    --port 8080 \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

gcloud compute health-checks create http fancy-be-hc \
    --port 8081 \
    --request-path=/api/orders \
    --check-interval 30s \
    --healthy-threshold 1 \
    --timeout 10s \
    --unhealthy-threshold 3

* --request-path: URL to send healthchecks. / if omitted

# create firewall rules for health checks
gcloud compute firewall-rules create allow-health-check \
    --allow tcp:8080-8081 \
    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --network default

# apply health checks for respective managed instance group

gcloud compute instance-groups managed update fancy-fe-mig \
    --health-check fancy-fe-hc \
    --initial-delay 300

gcloud compute instance-groups managed update fancy-be-mig \
    --health-check fancy-be-hc \
    --initial-delay 300

---------------------------------------------------

# CREATE LOAD BALANCERS

# create health checks for LB
gcloud compute http-health-checks create fancy-fe-frontend-hc \
  --request-path / \
  --port 8080

gcloud compute http-health-checks create fancy-be-orders-hc \
  --request-path /api/orders \
  --port 8081

gcloud compute http-health-checks create fancy-be-products-hc \
  --request-path /api/products \
  --port 8082

# create backend services
* will use the named ports
gcloud compute backend-services create fancy-fe-frontend \
  --http-health-checks fancy-fe-frontend-hc \
  --port-name frontend \
  --global

gcloud compute backend-services create fancy-be-orders \
  --http-health-checks fancy-be-orders-hc \
  --port-name orders \
  --global

gcloud compute backend-services create fancy-be-products \
  --http-health-checks fancy-be-products-hc \
  --port-name products \
  --global

# add MIGs to backend services

gcloud compute backend-services add-backend fancy-fe-frontend \
  --instance-group fancy-fe-mig \
  --instance-group-zone us-central1-f \
  --global

gcloud compute backend-services add-backend fancy-be-orders \
  --instance-group fancy-be-mig \
  --instance-group-zone us-central1-f \
  --global

gcloud compute backend-services add-backend fancy-be-products \
  --instance-group fancy-be-mig \
  --instance-group-zone us-central1-f \
  --global

# create URL map
gcloud compute url-maps create fancy-map \
  --default-service fancy-fe-frontend

# add path-matcher to url maps
gcloud compute url-maps add-path-matcher fancy-map \
   --default-service fancy-fe-frontend \
   --path-matcher-name orders \
   --path-rules "/api/orders=fancy-be-orders,/api/products=fancy-be-products"

# create proxy that ties to URL maps
gcloud compute target-http-proxies create fancy-proxy \
  --url-map fancy-map

# create a forwarding rule that ties a public IP and port to the proxy
gcloud compute forwarding-rules create fancy-http-rule \
  --global \
  --target-http-proxy fancy-proxy \
  --ports 80

* when traffic gets to this IP and port, it will be forwarded to the proxy, which will use URL map to send it further

# view the IP and port bind to the proxy
gcloud compute forwarding-rules list --global

# change the .env file
replace [LB_IP] with IP address

REACT_APP_ORDERS_URL=http://[LB_IP]/api/orders
REACT_APP_PRODUCTS_URL=http://[LB_IP]/api/products

# build the app again and push code to bucket
cd ~/monolith-to-microservices/react-app
npm install && npm run-script build

cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

-----------------------------------------------

# update frontend instance
* use rolling restart command so instance will pull code at startup

gcloud compute instance-groups managed rolling-action replace fancy-fe-mig \
    --max-unavailable 100%

# monitor the instance groups
watch -n 2 gcloud compute instance-groups list-instances fancy-fe-mig

watch -n 2 gcloud compute backend-services get-health fancy-fe-frontend --global

---------------------------------------------

# scaling
gcloud compute instance-groups managed set-autoscaling \
  fancy-fe-mig \
  --max-num-replicas 2 \
  --target-load-balancing-utilization 0.60

gcloud compute instance-groups managed set-autoscaling \
  fancy-be-mig \
  --max-num-replicas 2 \
  --target-load-balancing-utilization 0.60

# enable CDN
gcloud compute backend-services update fancy-fe-frontend \
    --enable-cdn --global

-----------------------------------------

# UPDATE instance template

# change the frontend instance
gcloud compute instances set-machine-type frontend --machine-type custom-4-3840

# create new instance template
gcloud compute instance-templates create fancy-fe-new \
    --source-instance=frontend \
    --source-instance-zone=us-central1-f

# roll out update on frontend MIG
gcloud compute instance-groups managed rolling-action start-update fancy-fe-mig \
    --version template=fancy-fe-new

# monitor the instance group
watch -n 2 gcloud compute instance-groups managed list-instances fancy-fe-mig

# check the updated machine type
gcloud compute instances describe [VM_NAME] | grep machineType

----------------------------------------------

# MAKE CHANGE TO WEBSITE

# add a file
cd ~/monolith-to-microservices/react-app/src/pages/Home
mv index.js.new index.js

# build and push code to bucket

cd ~/monolith-to-microservices/react-app
npm install && npm run-script build

cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

# rollout update
gcloud compute instance-groups managed rolling-action replace fancy-fe-mig \
    --max-unavailable=100%

# monitor the instance group
watch -n 2 gcloud compute instance-groups list-instances fancy-fe-mig

watch -n 2 gcloud compute backend-services get-health fancy-fe-frontend --global

---------------------------------------------

# simulate failure

gcloud compute instance-groups list-instances fancy-fe-mig

gcloud compute ssh [INSTANCE_NAME]

sudo supervisorctl stop nodeapp; sudo killall node

exit

# monitor the repair

watch -n 2 gcloud compute operations list \
--filter='operationType~compute.instances.repair.*'

