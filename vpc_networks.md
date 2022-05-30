# create network in console
In the Cloud Console, navigate to Navigation menu > VPC network > VPC networks.

create the network and subnet at the same time

# create network in cloud shell
gcloud compute networks create privatenet --subnet-mode=custom

gcloud compute networks subnets create privatesubnet-us --network=privatenet --region=us-central1 --range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-eu --network=privatenet --region=europe-west4 --range=172.20.0.0/20

--> subnets are regional, but they can talk to each other if they are in the same network

# see networks and subnets
gcloud compute networks list

gcloud compute networks subnets list --sort-by=NETWORK


# create firewall rule for a network
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=icmp,tcp:22,tcp:3389 --source-ranges=0.0.0.0/0

# see all firewall rules
gcloud compute firewall-rules list --sort-by=NETWORK

# create vm with network interface
gcloud compute instances create privatenet-us-vm --zone=us-central1-f --machine-type=n1-standard-1 --subnet=privatesubnet-us

# see all VM instances
gcloud compute instances list --sort-by=ZONE

