ExUnit.start
Application.ensure_all_started(:bypass)

defmodule PathHelpers do
  def fixture_path do
    Path.expand("fixtures", __DIR__)
  end

  def fixture_path(file_path) do
    Path.join fixture_path, file_path
  end

  def load_json(file_path) do
    case file_path |> fixture_path |> File.read do
      {:ok, file}      -> {:ok, Poison.decode!(file)}
      {:error, reason} -> {:error, reason}
    end
  end
end
