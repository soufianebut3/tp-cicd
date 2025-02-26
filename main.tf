resource "null_resource" "build_push_docker_image" {
  provisioner "local-exec" {
    command = <<EOT
      gcloud builds submit --tag gcr.io/${var.project_id}/my-app:latest ${path.module}/../application
    EOT
  }
}




terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
