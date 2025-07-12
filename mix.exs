defmodule ExProxyServer.MixProject do
  use Mix.Project

  @app :ex_proxy_server

  def project do
    [
      app: @app,
      version: "0.2.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      default_release: @app,
      releases: releases(),
      preferred_cli_env: [release: :prod]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExProxyServer.Application, []}
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.7"},
      {:websock_adapter, "~> 0.5"}
    ]
  end

  defp releases do
    [
      ex_proxy_server: [
        version: {:from_app, @app},
        cookie: "#{@app}_cookie",
        quiet: true,
        overwrite: true,
        steps: [:assemble],
        include_erts: false,
        include_executables_for: [:unix],
        strip_beams: Mix.env() == :prod
      ]
    ]
  end
end
