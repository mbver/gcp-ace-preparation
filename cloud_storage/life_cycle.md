# view life_cycle_policy of a bucket 
gsutil lifecycle get gs://$BUCKET_NAME_1

# example rule
```json
{
  "rule":
  [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 31}
    }
  ]
}
```
# set policy
gsutil lifecycle set life.json gs://$BUCKET_NAME_1