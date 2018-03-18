defmodule StopUnwantedCalls.Blacklist do
  @moduledoc """
  Module implements checl on blacklist
  """
  require Logger
  @path_env %{dev: "blacklist.txt", test: "blacklist_test.txt"}
  @path Path.join(["lib/stop_unwanted_calls/call", @path_env[Mix.env()]])

  def is_blacklisted?(caller_id_number) do
    File.stream!(@path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.any?(fn line ->
      line == caller_id_number
    end)
  end
end
