defmodule UQuery.Counter do
  @moduledoc """
  Counts for query.
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
