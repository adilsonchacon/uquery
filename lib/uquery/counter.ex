defmodule UQuery.Counter do
  @moduledoc """
  Counts for query.
  """

  @doc """
  Add to your Repo file the "count" method following the example below:

  ```
  defmodule MyApp.Repo do
    use Ecto.Repo,
      otp_app: :my_app,
      adapter: Ecto.Adapters.Postgres

    ...

    def count(query) do
      UQuery.Counter.count(__MODULE__, query)
    end

    ...

  end
  ```

  Now call the method above in your models:

  ```
  defmodule MyApp.Projects do
    ...

    import Ecto.Query, warn: false
    alias MyApp.Repo

    alias MyApp.Projects.Project

    ...

    def count_projects() do
      from(p in Project, select: p)
      |> Repo.count()
    end

    ...

  end
  ```
  """

  import Ecto.Query, warn: false

  def count(repo, %Ecto.Query{} = query) do
    query
    |> exclude(:select)
    |> exclude(:order_by)
    |> select(count("*"))
    |> repo.one()
  end
end
