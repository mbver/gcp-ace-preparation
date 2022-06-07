resource "google_compute_instance" "tf-instance-1" {
    name = "tf-instance-1"
    machine_type = "n1-standard-2"
    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-10"
        }
    }
    network_interface {
        network = "tf-vpc-350191"
        subnetwork = "subnet-01"
        access_config {
        }
    }
    metadata_startup_script = <<-EOT
            #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-2" {
    name = "tf-instance-2"
    machine_type = "n1-standard-2"
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }
    network_interface {
        network = "tf-vpc-350191"
        subnetwork = "subnet-02"
        access_config {
        }
    }
    metadata_startup_script = <<-EOT
            #!/bin/bash
        EOT
    allow_stopping_for_update = true
}

resource "google_compute_instance" "tf-instance-311267" {
    name = "tf-instance-311267"
    machine_type = "n1-standard-2"
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-10"
        }
    }
    network_interface {
        network = "default"
        access_config {
        }
    }
    metadata_startup_script = <<-EOT
            #!/bin/bash
        EOT
    allow_stopping_for_update = true
}