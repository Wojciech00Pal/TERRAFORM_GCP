# Configure GCP project
provider "google" {
  project = var.project_id
}

# Deploy image to Cloud Run
resource "google_cloud_run_service" "my-service" {
  name     = var.service_name
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.image_name}:${var.image_tag}"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Create public access (use with caution)
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Enable public access on Cloud Run service (use with caution)
resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.my_service.location
  project     = google_cloud_run_service.my_service.project
  service     = google_cloud_run_service.my_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Return service URL
output "url" {
  value = "${google_cloud_run_service.my-service.status[0].url}"
}