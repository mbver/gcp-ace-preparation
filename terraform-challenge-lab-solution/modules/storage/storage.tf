resource "google_compute_storage" "tf-bucket-564749" {
    name = "tf-bucket-564749"
    location = "US"
    force_destroy = true
    uniform_bucket_access_level = true
}