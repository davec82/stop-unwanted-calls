defmodule StopUnwantedCalls.Test.Support.EventProtocol do
  use GenServer

  # Client API

  def start_link(test_pid, params) do
    GenServer.start_link(__MODULE__, {test_pid, params}, [])
  end

  # Server Callbacks

  def init({test_pid, params}) do
    {:ok, %{:test_pid => test_pid, :params => params}}
  end

  def handle_call({{:execute}, {command, args}}, _from, state) do
    send(state.test_pid, {:execute, command, args})
    {:reply, {:ok, %{}}, state}
  end

  def handle_call({:connect}, _from, state) do
    send(state.test_pid, {:connect})
    params = state.params

    data = %{
      "Channel-Destination-Number" => Map.get(params, :called_id_number),
      "variable_effective_caller_id_number" =>
        Map.get(params, :caller_id_number),
      "Channel-Unique-ID" => "538c7d22-e705-11e7-bc33-73bec77e82ec"
    }

    {:reply, {:ok, data}, state}
  end

  def handle_call({{:filter}, {args}}, _from, state) do
    send(state.test_pid, {:filter, args})
    {:reply, {:ok, %{}}, state}
  end

  def handle_call({{:eventplain}, {args}}, _from, state) do
    send(state.test_pid, {:eventplain, args})
    {:reply, {:ok, %{}}, state}
  end

  def handle_call({{:hangup}, {reason}}, _from, state) do
    send(state.test_pid, {:hangup, reason})
    {:reply, {:ok, %{}}, state}
  end
end
