Deploying Google Kubernetes Engine


# change number of nodes in clusters
- In the Google Cloud Console, click NODES at the top of the details page for standard-cluster-1.
- In Node Pools section, click default-pool.
- In the Google Cloud Console, click RESIZE at the top of the Node Pool Details page.
- Change the number of nodes from 3 to 4 and click RESIZE.

# deploy a sample workload
- Navigation menu -> click Kubernetes Engine > Workloads.
- Click Deploy to show the Create a deployment wizard.
- Click Continue to accept the default container image, nginx:latest, which deploys 3 Pods each with a single container running the latest version of nginx.
- Scroll to the bottom of the window and click the Deploy button leaving the Configuration details at the defaults.

# view details about workload
- Navigation menu, click Kubernetes Engine > Workloads.
- In the Google Cloud Console, on the Kubernetes Engine > Workloads page, click nginx-1.
- Click the Revision History tab. This displays a list of the revisions that have been made to this workload.
- Click the Events tab. This tab lists events associated with this workload.
- And then the YAML tab. This tab provides the complete YAML file that defines this components and full configuration of this sample workload.

# view Pods details
- Still in the Google Cloud Console's Details tab for the nginx-1 workload, click the Overview tab, scroll down to the Managed Pods section and click the name of one of the Pods to view the details page for that Pod.
- The Pod Details page provides information on the Pod configuration and resource utilization and the node where the Pod is running.
- In the Pod details page, you can click the Events and Logs tabs to view event details and links to container logs in Cloud Operations.
- Click the YAML tab to view the detailed YAML file for the Pod configuration.
