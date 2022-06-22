# check versioning status
gsutil versioning get gs://$BUCKET_NAME_1
--> suspended means is not enabled

# enable versioning
gsutil versioning set on gs://$BUCKET_NAME_1

# copy a file with versioning option
gsutil cp -v setup.html gs://$BUCKET_NAME_1

# list all versions of a file
gsutil ls -a gs://$BUCKET_NAME_1/setup.html

# store a version name of a file
gs://BUCKET_NAME_1/setup.html#1584457872853517

# download the file
gsutil cp $VERSION_NAME recovered.txt
