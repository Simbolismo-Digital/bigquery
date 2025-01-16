defmodule Bigquery.Response do
  @moduledoc """
  Helper module to extract more useful data out of query responses from the `GoogleApi.BigQuery` library.

  for {:google_api_big_query, "~> 0.87.0"},

  original gist: https://gist.github.com/amokan/8398342d19faf4473b20e050e022b620
  """

  alias GoogleApi.BigQuery.V2.Model.{QueryResponse, TableSchema}

  @empty_values [nil, %{}, []]

  @doc """
  Parse the output of a `GoogleApi.BigQuery.V2.Api.Jobs.bigquery_jobs_query/4` call.
  """
  def process_results({:ok, %QueryResponse{} = results}),
    do: process_results(results)

  def process_results({:error, error_msg}), do: {:error, error_msg}

  def process_results(%QueryResponse{schema: schema, rows: _rows} = results) do
    results
    |> Map.update!(:rows, &merge_rows_with_schema(schema, &1))
    |> Map.update(:totalBytesProcessed, 0, &maybe_string_to_integer/1)
    |> Map.update(:totalRows, 0, &maybe_string_to_integer/1)
    |> Map.from_struct()
    |> Enum.map(fn {k, v} ->
      {snake_case_key(k), v}
    end)
    |> Map.new()
  end

  def process_results(_), do: {:error, :unexpected_args}

  defp merge_rows_with_schema(nil, nil), do: []
  defp merge_rows_with_schema(%TableSchema{} = _schema, nil), do: []

  defp merge_rows_with_schema(%TableSchema{} = schema, rows) when is_list(rows) do
    rows |> struct_to_map() |> Enum.map(&_merge_rows_with_schema(schema.fields, &1["f"]))
  end

  defp struct_to_map(value), do: value |> Poison.encode!() |> Poison.decode!()

  defp _merge_rows_with_schema(_schema, fields) when fields in @empty_values, do: []

  defp _merge_rows_with_schema(schema, fields) do
    fields
    |> Stream.with_index()
    |> Enum.reduce([], fn {field, i}, acc -> [merge_row(Enum.at(schema, i), field)] ++ acc end)
    |> Enum.into(%{})
  end

  defp merge_row(schema_field, field) do
    with converted_value <- convert(schema_field.mode, schema_field.type, schema_field, field) do
      {schema_field.name, converted_value}
    end
  end

  defp convert(_mode, _type, _schema, value) when value in @empty_values, do: nil

  defp convert("REPEATED", type, schema, field),
    do: field["v"] |> Enum.map(&convert(nil, type, schema, &1))

  defp convert(_mode, "RECORD", schema, field),
    do: _merge_rows_with_schema(schema.fields, field["v"]["f"])

  defp convert(_mode, _type, schema, field), do: convert_primitive(schema.type, field["v"])

  defp convert_primitive(_type, value) when value in @empty_values, do: nil
  defp convert_primitive("STRING", value), do: value
  defp convert_primitive("BOOLEAN", value), do: value == "true"
  defp convert_primitive("BOOL", value), do: value == "true"
  defp convert_primitive("FLOAT", value), do: string_to_float(value)
  defp convert_primitive("NUMERIC", value), do: string_to_float(value)
  defp convert_primitive("BIGNUMERIC", value), do: string_to_float(value)
  defp convert_primitive("INTEGER", value), do: String.to_integer(value)
  defp convert_primitive("DATE", value), do: value
  defp convert_primitive("DATETIME", value), do: value

  defp convert_primitive("TIMESTAMP", value) do
    (string_to_float(value) * 1_000_000)
    |> trunc()
  end

  defp convert_primitive("JSON", value) when is_binary(value), do: Jason.decode!(value)

  defp maybe_string_to_integer(nil), do: 0
  defp maybe_string_to_integer(value) when is_integer(value), do: value
  defp maybe_string_to_integer(value) when is_binary(value), do: String.to_integer(value)

  defp string_to_float(nil), do: 0.0
  defp string_to_float(""), do: 0.0

  defp string_to_float(value) do
    with value_temp <- String.trim(value) do
      case Regex.run(~r/[-+]?[0-9]*\.?[0-9]+/iux, value_temp) do
        nil ->
          0.0

        regex_result ->
          case regex_result |> Enum.at(0) |> Float.parse() do
            {integer, _} -> integer
            :error -> 0.0
          end
      end
    end
  end

  defp snake_case_key(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> snake_case_string()
    |> String.to_atom()
  end

  defp snake_case_string(value) when is_binary(value) do
    value
    |> String.replace(~r/([A-Z]+)([A-Z][a-z])/, "\\1_\\2")
    |> String.replace(~r/([a-z\d])([A-Z])/, "\\1_\\2")
    |> String.replace(~r/-/, "_")
    |> String.downcase()
  end
end
