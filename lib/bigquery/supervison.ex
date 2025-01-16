defmodule Bigquery.Supervisor do
  use Supervisor

  @impl true
  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    credentials = Application.get_env(:goth, :google_bigquery_credentials)

    children = [
      {Goth, name: Cashout.Goth, source: {:service_account, credentials, []}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
