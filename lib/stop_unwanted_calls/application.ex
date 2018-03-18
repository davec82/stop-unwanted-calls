defmodule LoginPhoneCall.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised

    children =
      case Application.get_env(:login_phone_call, :environment) do
        :test ->
          []

        _ ->
          ref = make_ref()

          socket_port =
            Application.get_env(:login_phone_call, :socket_port, 8084)

          ranch_listener_spec =
            :ranch.child_spec(
              ref,
              10,
              :ranch_tcp,
              [{:port, socket_port}],
              EventSocketOutbound.Protocol,
              :ranch
            )

          [ranch_listener_spec]
          # EventSocketOutbound.start_link()
      end

    opts = [strategy: :one_for_one, name: LoginPhoneCall.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
