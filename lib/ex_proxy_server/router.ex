defmodule ExProxyServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, 200, "23333!")
  end
end
