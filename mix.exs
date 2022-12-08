defmodule ExProxyServer.MixProject do
  use Mix.Project

  @app :ex_proxy_server

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      {:plug_cowboy, "~> 2.4"},
      {:bakeware, "~> 0.2", runtime: false}
    ]
  end

  defp releases do
    [
      ex_proxy_server: [
        version: {:from_app, @app},
        cookie: "#{@app}_cookie",
        quiet: true,
        overwrite: true,
        steps: [:assemble, &Bakeware.assemble/1],
        include_erts: include_erts(),
        include_executables_for: [:unix],
        strip_beams: Mix.env() == :prod
      ]
    ]
  end

  defp include_erts do
    case System.fetch_env("OTP_ERTS") do
      {:ok, path} -> path
      _ -> true
    end
  end
end
