Application.ensure_all_started(:postgrex)
Application.ensure_all_started(:ecto)

_ = Ecto.Adapters.Postgres.storage_down(UQuery.Repo.config())
_ = Ecto.Adapters.Postgres.storage_up(UQuery.Repo.config())
{:ok, _} = UQuery.Repo.start_link()
Ecto.Migrator.up(UQuery.Repo, 0, UQuery.Migrations, log: false)

Ecto.Adapters.SQL.Sandbox.mode(UQuery.Repo, :manual)

ExUnit.start()
