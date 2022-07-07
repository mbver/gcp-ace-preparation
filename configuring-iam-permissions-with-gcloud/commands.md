# install cloud sdk
curl https://sdk.cloud.google.com | bash

exec -l $SHELL

# configuring a gcloud environment

gcloud auth login --no-launch-browser

# install beta component
gcloud components install beta

# create an instance
gcloud compute instances create lab-1

# see available zones
gcloud compute zones list

# set zone
gcloud config set compute/zone ZONE

# start a new cloud config
gcloud init --no-launch-browser

# activate default config
gcloud config configurations activate default

# see names of roles
gcloud iam roles list | grep "name:"

# see details of a role
gcloud iam roles describe roles/compute.instanceAdmin

# activate configuration of user2
gcloud config configurations activate user2

# test if user2 has access to PROJECTID_2
gcloud config set project $PROJECTID2

# add user2 as project viewer for project 2
. ~/.bashrc
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/viewer

# create a custom role
gcloud iam roles create devops --project $PROJECTID2 --permissions "compute.instances.create,compute.instances.delete,compute.instances.start,compute.instances.stop,compute.instances.update,compute.disks.create,compute.subnetworks.use,compute.subnetworks.useExternalIp,compute.instances.setMetadata,compute.instances.setServiceAccount"

# bind user2 as serviceAccountUser on project2
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/iam.serviceAccountUser

# bind user2 to devops role on project2
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=projects/$PROJECTID2/roles/devops

# create a service account devops
gcloud iam service-accounts create devops --display-name devops

# get the service account email
gcloud iam service-accounts list  --filter "displayName=devops"

# store service account email address
SA=$(gcloud iam service-accounts list --format="value(email)" --filter "displayName=devops")

# bind the devops service account to service account user role
gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/iam.serviceAccountUser

# bind the service account to the role compute instance admin
gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/compute.instanceAdmin

# create instance with service account devops attached
gcloud compute instances create lab-3 --service-account $SA --scopes "https://www.googleapis.com/auth/compute"

* A best practice is to set the full cloud-platform access scope on the instance, then securely limit the service account's API access with IAM roles.

* user2 has the role devops, which can create an instance
* he can then create an instance with the service account, which has compute instance admin role
* he can access to that instance and use full APIs of compute engine storage!