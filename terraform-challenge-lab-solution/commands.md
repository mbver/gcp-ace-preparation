# import
terraform import module.my-instances.google_compute_instance.tf-instance-1 qwiklabs-gcp-01-c3d154893d00/us-central1-a/tf-instance-1

terraform import module.my-instances.google_compute_instance.tf-instance-2 qwiklabs-gcp-01-c3d154893d00/us-central1-a/tf-instance-2

# taint
terraform taint module.my-instances.google_compute_instance.tf-instance-311267