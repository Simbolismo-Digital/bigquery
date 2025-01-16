defmodule Bigquery.MixProject do
  use Mix.Project

  def project do
    [
      app: :bigquery,
      version: "0.0.1",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "A package for interacting with official Google BigQuery API",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # mod: {Bigquery.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:google_api_big_query, "~> 0.87.0"},
      {:goth, "~> 1.4"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "bigquery",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Simbolismo-Digital/bigquery"},
      files: ["lib", "mix.exs", "LICENSE", "README.md"]
    ]
  end

  defp docs do
    [
      main: "Bigquery",
      source_url: "https://github.com/Simbolismo-Digital/bigquery"
    ]
  end
end
