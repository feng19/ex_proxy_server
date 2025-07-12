import Config

config :logger, level: :info

config :logger, :console,
  # metadata: [:request_id, :module, :line],
  format: "$time [$level] $message\n"
