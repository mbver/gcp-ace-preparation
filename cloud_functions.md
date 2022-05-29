# create a bucket
gsutil mb -p [PROJECT_ID] gs://[BUCKET_NAME]

# deploy function
gcloud functions deploy helloWorld \
  --stage-bucket [BUCKET_NAME] \
  --trigger-topic hello_world \
  --runtime nodejs8

# we don't see topic used anywhere else!!!!!!

# test the function
DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'

# view logs
gcloud functions logs read helloWorld

