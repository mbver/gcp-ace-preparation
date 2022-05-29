gsutil cp ada.jpg gs://YOUR-BUCKET-NAME

gsutil cp -r gs://YOUR-BUCKET-NAME/ada.jpg .

# create a folder and copy!
gsutil cp gs://YOUR-BUCKET-NAME/ada.jpg gs://YOUR-BUCKET-NAME/image-folder/

gsutil ls gs://YOUR-BUCKET-NAME

gsutil ls -l gs://YOUR-BUCKET-NAME/ada.jpg

# make the file public
gsutil acl ch -u AllUsers:R gs://YOUR-BUCKET-NAME/ada.jpg

# remove public access
gsutil acl ch -d AllUsers gs://YOUR-BUCKET-NAME/ada.jpg

# delete object
gsutil rm gs://YOUR-BUCKET-NAME/ada.jpg