# create a topic
gcloud pubsub topics create myTopic

# view topic
gcloud pubsub topics list

# delete topic
gcloud pubsub topics delete Test1

# create subscription
gcloud  pubsub subscriptions create --topic myTopic mySubscription

# delete subscription
gcloud pubsub subscriptions delete Test1

# publish a message
gcloud pubsub topics publish myTopic --message "Hello"

# pull message
gcloud pubsub subscriptions pull mySubscription --auto-ack

# pull messages
gcloud pubsub subscriptions pull mySubscription --auto-ack --limit=3