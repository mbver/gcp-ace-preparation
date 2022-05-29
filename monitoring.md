# install monitoring and logging agents on VM
# monitoring agent
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh

sudo bash add-monitoring-agent-repo.sh

sudo apt-get update

sudo apt-get install stackdriver-agent

# logging agent
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh

sudo bash add-logging-agent-repo.sh

sudo apt-get update

sudo apt-get install google-fluentd


