import Config

encrypt_key = System.get_env("EX_PROXY_ENCRYPT_KEY", "90yT56qlvXmCdrrAnQsdb16HNm7lP6ySqi5tySHIr3o8C+Fr4B8URl5XH0NVssVI")

config :ex_proxy_server,
  port: System.get_env("PORT", "4000"),
  encrypt: {:once, encrypt_key}
