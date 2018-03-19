# Stop Unwanted Calls
[![Build Status](https://travis-ci.org/davec82/stop-unwanted-calls.png?branch=master)](https://travis-ci.org/davec82/stop-unwanted-calls)
[![Coverage Status](https://coveralls.io/repos/github/davec82/stop-unwanted-calls/badge.svg?branch=master)](https://coveralls.io/github/davec82/stop-unwanted-calls?branch=master)

`StopUnwantedCalls` is a simple Elixir application based on [Event Socket Outbound](https://hex.pm/packages/event_socket_outbound), an implementaion of FreeSWITCH's Event Socket Outbound, used to stop unwanted phone calls.

## Getting started

```elixir
# In your config/config.exs file
config :stop_unwanted_calls,
  socket_port: 8090,
  monkey_scream: "/opt/monkeys.wav",
  endpoint: "user/1001"
```
where *socket_port* will be the application listen port, *monkey_scream* a path to a soundfile to play when you receive a call from a blacklisted number, *endpoint* a suitable target endpoint for FreeSWITCH bridge app.

## Usage

1. In your FreeSWITCH dialplan define an extension where call control is passed to `StopUnwantedCalls` application.
```xml
<extension name="pstn">
  <condition field="destination_number" expression="12345678">
    <action application="socket" data="127.0.0.1:8090 async full"/>
  </condition>
</extension>
```

2. In blacklist.txt add phone numbers that will be blacklisted.

3. Start `StopUnwantedCalls` application!

## TODO

Add dynamically phone numbers to blacklist.