# Bigquery

https://hex.pm/packages/bigquery

## Run

.env must contain GOOGLE_BIGQUERY_CREDENTIALS (which is a json with the credentials for goth, exported from the google panel)

```sh
eval $(cat .env) iex -S mix
```

```ex
Bigquery.query_response("SELECT *
FROM dataset.table
WHERE true
LIMIT 1
")
```

# Adicionar deps

```ex
mix.exs
  defp deps do
    [
        ...
      {:bigquery, "~> 0.0.1"},
      ...
    ]
  end

  # if you are trying this project stand alone uncomment mod
  def application do
    [
      # mod: {Bigquery.Application, []},
      extra_applications: [:logger]
    ]
  end

  # if you are trying to run as a dep add this
  children =
      [
        ...
      ] ++ applications(Application.get_env(:your_app, :env))

  def applications(:test) do
    []
  end

  # :dev || :prod
  def applications(_) do
    [{Bigquery.Supervisor, []}]
  end
```

# Configurações

```ex
runtime.exs
unless config_env() == :test do
  # Fetch Google BigQuery credentials from environment variable
  google_bigquery_credentials =
    System.get_env("GOOGLE_BIGQUERY_CREDENTIALS")
    |> Jason.decode!()

  # Configure Goth with the service account credentials
  config :goth,
    google_bigquery_credentials: google_bigquery_credentials,
    google_bigquery_project_id: google_bigquery_credentials["project_id"]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/bigquery>.



