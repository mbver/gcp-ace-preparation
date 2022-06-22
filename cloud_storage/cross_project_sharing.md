# In project 1
- create a bucket and upload files to it
- create an IAM service account `cross-project-storage`
- set the permission for storage account as `storage-object-viewer`
- create a JSON key file from the service account

# In project 2
- create a VM instance and ssh to it
- store bucket name and file names in env
- upload the JSON key file for `cross-project-storage` service account
- activate the service account for VM
```sh
gcloud auth activate-service-account --key-file credentials.json
```
- verify access

# In project 1
- change service account permission to Object Storage Admin

# In project 2
- verify the VM can write to bucket