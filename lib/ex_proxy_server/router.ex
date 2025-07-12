defmodule ExProxyServer.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/ws" do
    conn
    |> WebSockAdapter.upgrade(ExProxyServer.SocketHandler, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    send_resp(conn, 200, "23333!")
  end
end
