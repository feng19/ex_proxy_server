defmodule ExProxyServerTest do
  use ExUnit.Case
  doctest ExProxyServer

  test "greets the world" do
    assert ExProxyServer.hello() == :world
  end
end
