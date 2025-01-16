defmodule Bigquery do
  @moduledoc """
  Bigquery API:
    `query_response` brings the query in json
    `query_lake` brings the query as raw QueryResponse

    you can use the same query from the web console
  """
  def query_response(query) do
    query_lake(query)
    |> response()
  end

  def query_lake(query) do
    alias GoogleApi.BigQuery.V2.Connection
    alias GoogleApi.BigQuery.V2.Model.QueryRequest

    alias GoogleApi.BigQuery.V2.Api.Jobs

    project_id = Application.get_env(:goth, :google_bigquery_project_id)

    %{token: token} = google_oauth_token!()
    conn = Connection.new(token)

    query_request = %QueryRequest{
      query: query,
      useLegacySql: false
    }

    query_options = [
      body: query_request,
      access_token: token,
      alt: "json"
    ]

    Jobs.bigquery_jobs_query(conn, project_id, query_options)
  end

  defp google_oauth_token! do
    Goth.fetch!(Cashout.Goth)
  end

  defp response({:ok, %GoogleApi.BigQuery.V2.Model.QueryResponse{} = query_response}) do
    %{rows: response} = Bigquery.Response.process_results(query_response)

    response
  end

  defp response(any), do: any
end
