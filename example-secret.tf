resource "google_secret_manager_secret" "database_credentials" {
  secret_id = "database-credentials"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "database_credentials" {
  secret = google_secret_manager_secret.database_credentials.id
  secret_data = file("helm/external-secrets/example_secret.txt")
}

resource "kubectl_manifest" "database_credentials" {
  yaml_body = file("helm/external-secrets/external_secret.yaml")
}
