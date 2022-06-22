# Customer-Supplied encryption key:
- change encryption_key field in .boto file
- upload local files
- download files in the bucket
==> all the files can be decrypted without rewrite

# change CSEK
- change encryption_key
- change decryption_key to previous encryption_key
- rewrite the files
```sh
gsutil rewrite -k gs://$BUCKET_NAME_1/setup2.html
```
- delete the decryption_key in .boto file
- download the files and check

