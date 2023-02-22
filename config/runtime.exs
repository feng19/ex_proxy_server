import Config

encrypt_key = System.fetch_env!("EXPS_ENCRYPT_KEY")

config :ex_proxy_server,
  port: System.get_env("EXPS_PORT", "4000"),
  encrypt: {:once, encrypt_key}
