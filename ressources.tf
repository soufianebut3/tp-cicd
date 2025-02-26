# Créer un bucket Cloud Storage
resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region
}

# Créer un Service Account pour Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
}

# Attribuer les permissions nécessaires au Service Account
resource "google_project_iam_member" "cloud_run_sa_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Déployer l'application Flask sur Cloud Run
resource "google_cloud_run_service" "cloud_run" {
  name     = "flask-app"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email

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

# Autoriser Cloud Run à accéder au bucket
resource "google_storage_bucket_iam_member" "cloud_run_access" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Rendre le service Cloud Run public
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.cloud_run.location
  service  = google_cloud_run_service.cloud_run.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
