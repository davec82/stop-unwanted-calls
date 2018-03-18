defmodule StopUnwantedCalls.Call do
  @moduledoc """
  Module implements call routing logic
  """
  @behaviour EventSocketOutbound.CallMgmt

  require Logger
  use GenServer
  alias StopUnwantedCalls.Blacklist

  @event_protocol Application.get_env(
                    :stop_unwanted_calls,
                    :event_protocol,
                    EventSocketOutbound.Protocol
                  )

  def start_link(pid) do
    GenServer.start_link(__MODULE__, {pid})
  end

  def onEvent(pid, event) do
    GenServer.cast(pid, {:event, event})
  end

  #
  # GenServer Callbacks
  #
  @doc false
  def init({pid}) do
    send(self(), :start_up)
    {:ok, %{:tcp_server => pid}}
  end

  @doc false
  def handle_cast({:event, %{"Event-Name" => "PLAYBACK_STOP"} = event}, state) do
    case Map.get(event, "unwanted_call") do
      nil ->
        nil

      "monkeys" ->
        @event_protocol.hangup(state.tcp_server)
    end

    {:noreply, state}
  end

  @doc false
  def handle_cast(
        {:event, %{"Event-Name" => "CHANNEL_UNBRIDGE"} = _event},
        state
      ) do
    @event_protocol.hangup(state.tcp_server)

    {:noreply, state}
  end

  @doc false
  def handle_cast({:event, _event}, state) do
    {:noreply, state}
  end

  @doc false
  def handle_info(:start_up, state) do
    {:ok, data} = @event_protocol.connect(state.tcp_server)
    _called_id_number = Map.get(data, "Channel-Destination-Number", "000000")

    caller_id_number =
      Map.get(data, "variable_effective_caller_id_number", "000000")

    my_uuid = Map.get(data, "Channel-Unique-ID")

    {:ok, _} = @event_protocol.filter(state.tcp_server, "Unique-ID " <> my_uuid)
    {:ok, _} = @event_protocol.eventplain(state.tcp_server, "PLAYBACK_STOP")
    {:ok, _} = @event_protocol.eventplain(state.tcp_server, "CHANNEL_UNBRIDGE")

    Logger.info("Caller id number is #{inspect(caller_id_number)}")

    case Blacklist.is_blacklisted?(caller_id_number) do
      true ->
        play_monkeys(state)

      _ ->
        endpoint = Application.get_env(:stop_unwanted_calls, :endpoint)
        {:ok, _} = @event_protocol.execute(state.tcp_server, "bridge", endpoint)
    end

    {:noreply, state}
  end

  defp play_monkeys(state) do
    sound_file = Application.get_env(:stop_unwanted_calls, :monkey_scream)
    playback_args = "{unwanted_call=monkeys}" <> sound_file

    {:ok, _} =
      @event_protocol.execute(state.tcp_server, "playback", playback_args)
  end
end
