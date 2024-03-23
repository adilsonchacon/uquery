defmodule UQuery.Repo do
  use Ecto.Repo,
    otp_app: :uquery,
    adapter: Ecto.Adapters.Postgres
end
