gcloud auth list

gcloud config list project

gcloud config set compute/region us-central1

gcloud config get-value compute/region

gcloud config set compute/zone us-central1-b

gcloud config get-value compute/zone

gcloud config get-value project

gcloud compute project-info describe --project $(gcloud config get-value project) 

# create vm
gcloud compute instances create gcelab2 --machine-type n1-standard-2 --zone $ZONE

# see help
gcloud compute instances create --help

gcloud -h

gcloud config --help

gcloud help config

# view config
gcloud config list

gcloud config list --all

# list components
gcloud components list

# list VM instances
gcloud compute instances list

# list only a VM
gcloud compute instances list --filter="name=('gcelab2')"

# list firewall rules
gcloud compute firewall-rules list

# list firewall rules for default network
gcloud compute firewall-rules list --filter="network='default'"

# list firewall rules for default network and ICMP
gcloud compute firewall-rules list --filter="NETWORK:'default' AND ALLOW:'icmp'"

# connect to a VM
gcloud compute ssh gcelab2 --zone $ZONE

# add tags to a VM
gcloud compute instances add-tags gcelab2 --tags http-server,https-server

# create a firewall rule to allow
gcloud compute firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

# list firewall rules that allows tcp:80
gcloud compute firewall-rules list --filter=ALLOW:'80'

# verify connectivity
curl http://$(gcloud compute instances list --filter=name:gcelab2 --format='value(EXTERNAL_IP)')

# view logging on system
gcloud logging logs list

gcloud logging logs list --filter="compute" 

# read a log
gcloud logging read "resource.type=gce_instance" --limit 5

# read log for a VM instance
gcloud logging read "resource.type=gce_instance AND labels.instance_name='gcelab2'" --limit 5