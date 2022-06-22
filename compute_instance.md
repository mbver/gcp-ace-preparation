# generate ssh key
https://cloud.google.com/compute/docs/connect/create-ssh-keys

ssh-keygen -t rsa -f ~/.ssh/baogadatac6 -C baogadatac6@gmail.com -b 2048


# OS Login-managed SSH connections
https://cloud.google.com/compute/docs/instances/ssh#gcloud_1

1. You use the gcloud compute ssh command to connect to your VM.
2. Compute Engine sets a username and creates a persistent SSH key pair with the following configurations:
Your username is the username set by your organization's Cloud Identity or Google Workspace administrator. If your organization hasn't configured a username for you, Compute Engine uses your Google Account email, in the following format:
USERNAME_DOMAIN_SUFFIX
For example, if the email associated with your Google Account is cloudysanfrancisco@gmail.com, then your generated username is cloudysanfrancisco_gmail_com.
Your public SSH key is stored in your Google Account.
You private SSH key is stored on your local machine in the google_compute_engine file.
Your SSH key doesn't have an expiry. It is used for all future SSH connections you make, unless you configure a new key.

3. Compute Engine resolves your provided username to your OS Login account in the VM using NSS service modules.

4. Compute Engine performs IAM authorization using PAM configurations, to ensure you have the required permissions to connect.

5. Compute Engine retrieves the SSH key from your user account and provides it to OpenSSH in the VM using the SSH authorized keys command.

6. Compute Engine grants your connection.

It didn't connect! LOL.

# check os-login profile
gcloud compute os-login describe-profile