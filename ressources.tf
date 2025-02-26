# Créer un bucket Cloud Storage
resource "google_storage_bucket" "bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
}

# Déployer l'application sur Cloud Run
resource "google_cloud_run_service" "cloud_run" {
  name     = "flask-app"
  location = var.region

  template {
    spec {
      containers {
        image = var.docker_image
        env {
          name  = "BUCKET_NAME"
          value = google_storage_bucket.bucket.name
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Donner l'accès au bucket au service Cloud Run
resource "google_storage_bucket_iam_member" "cloud_run_access" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_cloud_run_service.cloud_run.template[0].spec[0].service_account_name}"	
}

# Rendre le service Cloud Run public
resource "google_cloud_run_service_iam_member" "all_users_invoker" {
  location = google_cloud_run_service.cloud_run.location
  service  = google_cloud_run_service.cloud_run.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
