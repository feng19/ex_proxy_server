defmodule ExProxyServer.Application do
  @moduledoc false

  use Application
  @app :ex_proxy_server

  @impl true
  def start(_type, _args) do
    port =
      case Application.fetch_env!(@app, :port) do
        port when is_binary(port) -> String.to_integer(port)
        port when is_integer(port) -> port
      end

    children = [
      {Bandit, scheme: :http, plug: ExProxyServer.Router, ip: {0, 0, 0, 0}, port: port}
    ]

    opts = [strategy: :one_for_one, name: ExProxyServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
