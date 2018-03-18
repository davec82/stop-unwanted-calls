defmodule StopUnwantedCallsTest do
  use ExUnit.Case
  require Logger
  alias StopUnwantedCalls.Blacklist
  alias StopUnwantedCalls.Call
  alias StopUnwantedCalls.Test.Support.EventProtocol

  test "not in blacklist" do
    assert Blacklist.is_blacklisted?("1111") == false
  end

  test "in blacklist" do
    assert Blacklist.is_blacklisted?("0199999") == true
  end

  test "blacklisted number" do
    {:ok, proto_pid} =
      EventProtocol.start_link(self(), %{
        caller_id_number: "0199999",
        called_id_number: "0298181"
      })

    {:ok, call_pid} = Call.start_link(proto_pid)
    assert_receive {:connect}, 5000
    assert_receive {:filter, _args}, 5000
    assert_receive {:eventplain, _args}, 5000

    assert_receive {:execute, "playback", _}

    event = %{"Event-Name" => "PLAYBACK_STOP", "unwanted_call" => "monkeys"}
    Call.onEvent(call_pid, event)

    assert_receive {:hangup, _reason}, 5000
  end

  test "not blacklisted number" do
    {:ok, proto_pid} =
      EventProtocol.start_link(self(), %{
        caller_id_number: "00993393",
        called_id_number: "0298181"
      })

    {:ok, call_pid} = Call.start_link(proto_pid)
    assert_receive {:connect}, 5000
    assert_receive {:filter, _args}, 5000
    assert_receive {:eventplain, _args}, 5000
    assert_receive {:execute, "bridge", _}

    event = %{"Event-Name" => "CHANNEL_UNBRIDGE"}
    Call.onEvent(call_pid, event)

    assert_receive {:hangup, _reason}, 5000
  end
end
