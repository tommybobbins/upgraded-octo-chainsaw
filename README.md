# Provision a Google Cloud GCP GKE Autopilot Cluster and use external secrets

Demonstration of using kubernetes external secrets with Google Secret Manager. Based on the external-secrets.io [documentation](https://external-secrets.io/v0.8.3/provider/google-secrets-manager/)

## Not for production use.

Check that all the APIs are enabled
```
$ gcloud services list --enabled
NAME                                 TITLE
appengine.googleapis.com             App Engine Admin API
appenginereporting.googleapis.com    App Engine
autoscaling.googleapis.com           Cloud Autoscaling API
bigquerystorage.googleapis.com       BigQuery Storage API
certificatemanager.googleapis.com    Certificate Manager API
cloudapis.googleapis.com             Google Cloud APIs
cloudbuild.googleapis.com            Cloud Build API
clouddebugger.googleapis.com         Cloud Debugger API
cloudresourcemanager.googleapis.com  Cloud Resource Manager API
cloudscheduler.googleapis.com        Cloud Scheduler API
cloudtrace.googleapis.com            Cloud Trace API
compute.googleapis.com               Compute Engine API
container.googleapis.com             Kubernetes Engine API
containerregistry.googleapis.com     Container Registry API
datastore.googleapis.com             Cloud Datastore API
deploymentmanager.googleapis.com     Cloud Deployment Manager V2 API
iam.googleapis.com                   Identity and Access Management (IAM) API
iamcredentials.googleapis.com        IAM Service Account Credentials API
logging.googleapis.com               Cloud Logging API
monitoring.googleapis.com            Cloud Monitoring API
oslogin.googleapis.com               Cloud OS Login API
secretmanager.googleapis.com         Secret Manager API
servicemanagement.googleapis.com     Service Management API
serviceusage.googleapis.com          Service Usage API
```

Create a terraform.tfvars file containing something similar to the following:

    credentials_file  = "wibbly-flibble-stuff-morestuff.json"
    project           = "wibble-flibble-numbers"
    region            = "europe-west2"

Create the service account keys which will be used for terraform wibbly-flibble-stuff-morestuff.json using:

    $ gcloud iam service-accounts keys create wibbly-flibble-stuff-morestuff.json \
    --iam-account=SA_NAME@PROJECT_ID.iam.gserviceaccount.com 

This will create everything except the kubectl_manifests which must be created after getting the cluster credentials.
Run the below command to populate the ~/.kube/config:

    $ gcloud container clusters get-credentials <project_name>-gke --region europe-west2

Run terraform apply again which should output:

```
kubectl_manifest.database_credentials: Creating...
kubectl_manifest.cluster_secretstore: Creating...
kubectl_manifest.cluster_secretstore: Creation complete after 2s [id=/apis/external-secrets.io/v1beta1/clustersecretstores/gcp-store]
kubectl_manifest.database_credentials: Creation complete after 3s [id=/apis/external-secrets.io/v1beta1/namespaces/monitoring/externalsecrets/database-credentials]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

kubernetes_cluster_host = "1.2.3.4"
kubernetes_cluster_name = "wibbly-bibbly-12235-gke"
project = "wibbly-bibbly-12235"
region = "europe-west2"
```

Check secret has been created:

     $ kubectl get secrets -n monitoring
     NAME                   TYPE     DATA   AGE
     database-credentials   Opaque   2      6s

Retrieve the secrets : 

```
$ for secret in $(kubectl get secrets/database-credentials -n monitoring -o yaml | egrep "^  database_" | awk '{print $2}'); do echo "$secret" | base64 -d; echo; done
terriblepassword
tommybobbins
```
