import Config

config :uquery, ecto_repos: [UQuery.Repo]

config :uquery, UQuery.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  hostname: "0.0.0.0",
  username: "postgres",
  password: "aidentro!",
  database: "uquery_test",
  log: false
