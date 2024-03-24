defmodule UQuery.Paginator do
  @moduledoc """
  Documentation for `UQuery Paginator`.

  Paginates a query and returns items and metadata.
  """

  @doc """
  Add to your Repo file the "paginate" method following the example below:

  ```
  defmodule MyApp.Repo do
    use Ecto.Repo,
      otp_app: :my_app,
      adapter: Ecto.Adapters.Postgres

    ...

    def paginate(query, page, per_page) do
      UQuery.Paginator.paginate(__MODULE__, query, page, per_page)
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

    def list_projects(page, per_page) do
      from(p in Project, select: p)
      |> Repo.paginate(page, per_page)
    end

    ...

  end
  ```
  """
  import Ecto.Query, warn: false

  def paginate(repo, %Ecto.Query{} = query, page, per_page) when is_integer(page) and is_integer(per_page) do
    items = query_items(repo, query, page, per_page)
    count = UQuery.Counter.count(repo, query)
    last = get_last_page(count, per_page)
    first = get_first_page(last)
    prev = get_prev_page(page, first)
    next = get_next_page(page, last)
    serie = build_serie(page, last, prev, next)

    {
      items,
      %{
        count: count,
        page: page,
        per_page: per_page,
        first: first,
        last: last,
        prev: prev,
        next: next,
        serie: serie
      }
    }
  end

  def query_items(repo, %Ecto.Query{} = query, page, per_page) when is_integer(page) and is_integer(per_page) do
    limit = limit_per_page(per_page)
    offset = (page - 1) * limit
    repo.all(from query, limit: ^limit, offset: ^offset)
  end

  defp limit_per_page(per_page) do
    if per_page > 50 do
      50
    else
      per_page
    end
  end

  defp get_first_page(total) do
    if total > 0 do
      1
    else
      nil
    end
  end

  defp get_last_page(total, per_page) do
    pages = calculate_number_of_pages(total, per_page)

    if pages == 0 do
      nil
    else
      pages
    end
  end

  defp calculate_number_of_pages(total, per_page) do
    if per_page == 0 do
      0
    else
      div(total, per_page) + increment_if_remaining_great_than_one(total, per_page)
    end
  end

  defp increment_if_remaining_great_than_one(total, per_page) do
    if rem(total, per_page) > 0 do
      1
    else
      0
    end
  end

  defp get_next_page(page, last) do
    if is_nil(last) || page >= last do
      nil
    else
      page + 1
    end
  end

  defp get_prev_page(page, first) do
    if is_nil(first) || page <= 1 do
      nil
    else
      page - 1
    end
  end

  defp build_serie(page, last, prev, next) do
    series = []

    if is_nil(prev) && is_nil(next) do
      series
    else
      series = [page]
      while_push(series, 0, page, last)
    end
  end

  defp while_push(series, acc, page, last) do
    acc = acc + 1

    if (Enum.count(series) > 6) || (acc > last) do
      ellipsis_serie(series, last)
    else
      series
      |> increment_serie(acc, page, last)
      |> while_push(acc, page, last)
    end
  end

  defp increment_serie(series, acc, page, last) do
    series = if acc < page do
      [page - acc | series]
    else
      series
    end

    if (page + acc) <= last do
      Enum.concat(series, [page + acc])
    else
      series
    end
  end

  defp ellipsis_serie(series, last) do
    series = if Enum.at(series, 0) >= 3 do
      Enum.concat([1, "..."], series)
    else
      series
    end

    if last - Enum.at(series, Enum.count(series) - 1) >= 3 do
      Enum.concat(series, ["...", last])
    else
      series
    end
  end
end
