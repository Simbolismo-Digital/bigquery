defmodule Bigquery.MixProject do
  use Mix.Project

  def project do
    [
      app: :bigquery,
      version: "0.0.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bigquery.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:google_api_big_query, "~> 0.87.0"},
      {:goth, "~> 1.4"},
      {:jason, "~> 1.4"}
    ]
  end
end
