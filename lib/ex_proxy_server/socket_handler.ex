defmodule ExProxyServer.SocketHandler do
  @behaviour WebSock
  require Logger
  alias Plug.Crypto.MessageEncryptor
  @app :ex_proxy_server

  @ipv4 0x01
  @ipv6 0x04
  @domain 0x03

  # 1 => no encrypt packet
  @encrypt_none 1
  # 2 => just encrypt first packet
  @encrypt_once 2
  # 3 => encrypt all packet
  @encrypt_all 3

  @sign_secret "90de3456asxdfrtg"

  @impl true
  def init(_opts) do
    {encrypt_type, key} =
      case Application.get_env(@app, :encrypt, false) do
        false -> {@encrypt_none, nil}
        {:once, key} when is_binary(key) -> {@encrypt_once, key}
        {:all, key} when is_binary(key) -> {@encrypt_all, key}
      end

    {:ok, %{encrypt_type: encrypt_type, key: key, remote: nil}}
  end

  @impl true
  def handle_in({encrypted, [opcode: :binary]}, %{encrypt_type: @encrypt_all, key: key} = state) do
    case MessageEncryptor.decrypt(encrypted, key, @sign_secret) do
      {:ok, msg} -> send2remote(msg, state)
      :error -> {:stop, :normal, state}
    end
  end

  def handle_in({msg, [opcode: :binary]}, %{remote: nil, key: key} = state) do
    case connect2remote(msg, key) do
      {:ok, remote} ->
        :ok = :inet.setopts(remote, active: :once)
        {:ok, %{state | remote: remote}}

      {:error, error} ->
        Logger.error(inspect(error))
        {:stop, :normal, state}
    end
  end

  def handle_in({msg, [opcode: :binary]}, state), do: send2remote(msg, state)

  @impl true
  def handle_control({binary, opcode}, state) do
    Logger.warning("got opcode: #{opcode}, binary: #{inspect(binary)}")
    {:ok, state}
  end

  @impl true
  def handle_info({:tcp, _socket, response}, %{encrypt_type: @encrypt_all, key: key} = state) do
    response
    |> MessageEncryptor.encrypt(key, @sign_secret)
    |> receive_from_remote(state)
  end

  def handle_info({:tcp, _socket, response}, state), do: receive_from_remote(response, state)
  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}

  def handle_info({:tcp_error, _, reason}, state) do
    Logger.error(inspect(reason))
    {:stop, :normal, state}
  end

  def handle_info(_Info, state), do: {:ok, state}

  @impl true
  def terminate(_, %{remote: remote}) do
    if is_port(remote) do
      :gen_tcp.close(remote)
    end

    :ok
  end

  defp connect2remote(data, nil), do: connect2remote(data)

  defp connect2remote(encrypted, key) do
    case MessageEncryptor.decrypt(encrypted, key, @sign_secret) do
      {:ok, data} -> connect2remote(data)
      :error -> {:error, :decrypt_error}
    end
  end

  defp connect2remote(<<@ipv4, port::16, a, b, c, d>>) do
    connect_target({a, b, c, d}, port)
  end

  defp connect2remote(<<@ipv6, port::16, a::16, b::16, c::16, d::16, e::16, f::16, g::16, h::16>>) do
    connect_target({a, b, c, d, e, f, g, h}, port)
  end

  defp connect2remote(<<@domain, port::16, domain_len, address::binary-size(domain_len)>>) do
    address
    |> String.to_charlist()
    |> connect_target(port)
  end

  defp connect2remote(_), do: {:error, :bad_head}

  defp connect_target(address, port), do: connect_target(address, port, 2)
  defp connect_target(_, _, 0), do: {:error, :connect_failure}

  defp connect_target(address, port, retry_times) do
    case :gen_tcp.connect(address, port, [:binary, {:active, false}], 5000) do
      {:error, _error} -> connect_target(address, port, retry_times - 1)
      return -> return
    end
  end

  defp send2remote(msg, state) do
    case :gen_tcp.send(state.remote, msg) do
      :ok ->
        {:ok, state}

      {:error, error} ->
        Logger.error(inspect(error))
        {:stop, :normal, state}
    end
  end

  defp receive_from_remote(msg, state) do
    :ok = :inet.setopts(state.remote, active: :once)
    {:reply, :from_remote_to_client, [{:binary, msg}], state}
  end
end
