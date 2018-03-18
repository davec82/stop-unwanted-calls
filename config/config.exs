use Mix.Config

config :event_socket_outbound, EventSocketOutbound.Call.Manager,
  call_mgt_adapter: StopUnwantedCalls.Call

config :stop_unwanted_calls,
  socket_port: 8090,
  monkey_scream: "/opt/monkeys.wav",
  endpoint: "user/1001"

import_config "#{Mix.env()}.exs"
