variable "project_id" {
  description = "L'identifiant du projet GCP"
  type        = string
  default     = "zippy-pad-442508-s9"
}

variable "region" {
  description = "La région GCP"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "La zone GCP"
  type        = string
  default     = "europe-west1-b"
}

variable "bucket_name" {
  description = "Le nom du bucket Cloud Storage"
  type        = string
  default     = "notes-bucket-123456"
}

variable "docker_image" {
  description = "Le nom complet de l'image Docker à déployer sur Cloud Run"
  type        = string
  default     = "gcr.io/zippy-pad-442508-s9/flask-app"
}
