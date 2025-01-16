defmodule Bigquery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    credentials = Application.get_env(:goth, :google_bigquery_credentials)
    children = [{Goth, name: Cashout.Goth, source: {:service_account, credentials, []}}]

    Supervisor.start_link(children, strategy: :one_for_one, name: Bigquery.Supervisor)
  end
end
