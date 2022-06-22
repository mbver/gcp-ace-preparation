https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_2

# Create a firewall rule
To allow IAP to connect to your VM instances, create a firewall rule that:
- applies to all VM instances that you want to be accessible by using IAP.
- allows ingress traffic from the IP range 35.235.240.0/20. This range contains all IP addresses that IAP uses for TCP forwarding.
- allows connections to all ports that you want to be accessible by using IAP TCP forwarding, for example, port 22 for SSH and port 3389 for RDP.

```sh
gcloud compute firewall-rules create allow-rdp-ingress-from-iap \
  --direction=INGRESS \
  --action=allow \
  --rules=tcp:3389 \
  --source-ranges=35.235.240.0/20

gcloud compute firewall-rules create allow-ssh-ingress-from-iap \
  --direction=INGRESS \
  --action=allow \
  --rules=tcp:22 \
  --source-ranges=35.235.240.0/20
```

# Grant permissions to use IAP TCP forwarding
We recommend granting all of the following roles for trusted administrators:
  - roles/iap.tunnelResourceAccessor (project or VM)
  - roles/compute.instanceAdmin.v1 (project)

```sh
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member=user:EMAIL \
    --role=roles/iap.tunnelResourceAccessor
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member=user:EMAIL \
    --role=roles/compute.instanceAdmin.v1
```
# Tunneling SSH connections

```sh
gcloud compute ssh INSTANCE_NAME
```
You can use the --tunnel-through-iap flag so that gcloud compute ssh always uses IAP TCP tunneling.

Use the --internal-ip flag so that gcloud compute ssh never uses IAP TCP tunneling and instead directly connects to the internal IP of the VM. Doing so is useful for clients that are connected to the same VPC network as the target VM.

# Tunneling RDP connections
```sh
gcloud compute start-iap-tunnel INSTANCE_NAME 3389 \
    --local-host-port=localhost:LOCAL_PORT \
    --zone=ZONE
```
