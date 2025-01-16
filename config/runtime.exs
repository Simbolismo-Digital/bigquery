import Config

google_bigquery_credentials =
  System.get_env("GOOGLE_BIGQUERY_CREDENTIALS")
  |> Jason.decode!()

# Configure Goth with the service account credentials
config :goth,
  google_bigquery_credentials: google_bigquery_credentials,
  google_bigquery_project_id: google_bigquery_credentials["project_id"]
