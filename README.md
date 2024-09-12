# Uquery

Centralizes reusable SQL queries, e.g. for pagination and counting rows.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `uquery` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uquery, "~> 0.1.1"}
  ]
end
```

Run it in shell:
```
> mix deps.get
```


## Usage
```elixir
# in your repo file:
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres

  ...

  def paginate(query, page, per_page) do
    UQuery.Paginator.paginate(__MODULE__, query, page, per_page)
  end

  def pagination(query, page, per_page) do
    UQuery.Paginator.pagination(__MODULE__, query, page, per_page)
  end

  def count(query) do
    UQuery.Counter.count(__MODULE__, query)
  end

  ...

end

# in your models:
defmodule MyApp.Project do
  ...

  import Ecto.Query, warn: false
  alias MyApp.Repo

  alias MyApp.Projects.Project

  ...

  # List example 1
  def list_projects(page, per_page) do
    from(p in Project, select: p)
    |> Repo.paginate(page, per_page)
  end

  # List example 2
  def list_projects(page, per_page) do
    from(p in Project, select: p)
    { query, pagination } = Repo.pagination(page, per_page)
    { Repo.all(query), pagination }
  end

  # Count list
  def count_projects() do
    from(p in Project, select: p)
    |> Repo.count()
  end

  ...

end

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/uquery>.
