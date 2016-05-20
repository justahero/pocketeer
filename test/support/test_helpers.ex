defmodule PathHelpers do
  def fixture_path do
    Path.expand("../fixtures", __DIR__)
  end

  def fixture_path(file_path) do
    Path.join fixture_path, file_path
  end

  def load_json(file_path) do
    file_path |> fixture_path |> File.read
  end

  def load_json!(file_path) do
    case load_json(file_path) do
      {:ok, file}      -> file
      {:error, reason} -> raise reason
    end
  end
end

defmodule Pocketeer.TestHelpers do
  import ExUnit.Assertions
  import Plug.Conn
  import PathHelpers

  def bypass_server(%Bypass{port: port}) do
    "http://localhost:#{port}"
  end

  def bypass(server, method, path, function) do
    Bypass.expect server, fn conn ->
      connection = parse_request_body(conn)

      assert connection.method == method
      assert connection.request_path == path

      function.(connection)
    end
  end

  def build_client(options \\ %{}) do
    default_client_options
    |> Map.merge(options)
    |> Pocketeer.Client.new
  end

  def json_response(connection, status_code, file_path) do
    connection
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status_code, load_json!(file_path) |> Poison.encode!)
  end

  defp parse_request_body(connection) do
    options = [
      parsers: [:json],
      pass: ["*/*"],
      json_decoder: Poison
    ]
    Plug.Parsers.call(connection, Plug.Parsers.init(options))
  end

  defp default_client_options do
    %{consumer_key: "abcd", access_token: "1234"}
  end
end