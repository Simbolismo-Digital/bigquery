defmodule Bigquery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Start the Bigquery Supervisor, which will handle starting Goth
    Supervisor.start_link([{Bigquery.Supervisor, []}], strategy: :one_for_one, name: Bigquery.Application)
  end
end
