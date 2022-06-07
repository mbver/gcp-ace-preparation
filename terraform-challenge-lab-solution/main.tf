provider "google" {
    version = "~> 3.45.0"
    project = var.project_id
    region = var.region
    zone = var.zone
}

terraform {
    backend "local" {
        path = "terraform/state/terraform.tfstate"
    }
}

module "my-instances" {
    source = "./modules/instances"
}

module "my-network" {
    source = "terraform-google-modules/network/google"
    version = "~> 3.4.0"
    project_id = var.project_id
    network_name = "tf-vpc-350191"
    mtu = 1460
    subnets = [
        {
            subnet_name = "subnet-01"
            subnet_ip = "10.10.10.0/24"
            subnet_region = "us-central1"
        },
        {
            subnet_name = "subnet-02"
            subnet_ip = "10.10.20.0/24"
            subnet_region = "us-central1"
        }
    ]
}

resource "google_compute_firewall" "tf-firewall" {
    name = "tf-firewall"
    network = "tf-vpc-350191"
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
    source_ranges = ["0.0.0.0/0"]
}