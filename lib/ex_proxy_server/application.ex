defmodule ExProxyServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
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
      {Plug.Cowboy,
       scheme: :http,
       plug: ExProxyServer,
       port: port,
       dispatch: dispatch(),
       transport_options: [num_acceptors: 10]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExProxyServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dispatch do
    encrypt_setting =
      Application.get_env(
        @app,
        :encrypt,
        {:once, "90yT56qlvXmCdrrAnQsdb16HNm7lP6ySqi5tySHIr3o8C+Fr4B8URl5XH0NVssVI"}
      )

    [
      {:_,
       [
         {"/ws", ExProxyServer.SocketHandler, [encrypt: encrypt_setting]},
         {:_, Plug.Cowboy.Handler, {ExProxyServer.Router, []}}
       ]}
    ]
  end
end
