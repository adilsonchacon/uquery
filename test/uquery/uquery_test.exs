require Integer

defmodule UQueryTest do
  use ExUnit.Case, async: true
  # doctest UQuery

  import Ecto.Query

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(UQuery.Repo)
    # Setting the shared mode must be done only after checkout
    Ecto.Adapters.SQL.Sandbox.mode(UQuery.Repo, {:shared, self()})
  end

  test "count/2 counts total in table" do
    load_people(30)

    query = from(p in UQuery.Person, select: p)
    assert UQuery.Counter.count(UQuery.Repo, query) == 30
  end

  test "count/2 counts filtered by where" do
    load_people(30)

    query = from(p in UQuery.Person, select: p, where: like(p.name, "%8%"))
    assert UQuery.Counter.count(UQuery.Repo, query) == 3
  end

  test "count/2 counts filtered by where and join tables" do
    people = load_people(30)
    Enum.map_reduce(people, 0, fn(person, acc) ->
      {type, content} = if Integer.is_even(acc) do
        {"email", "user_#{person.id}@email.com"}
      else
        {"phone", "#{person.id}"}
      end

      {load_contact_for_person(person, type, content), acc + 1}
    end)

    query = from(
      p in UQuery.Person,
      join: c in UQuery.Contact,
      on: p.id == c.person_id,
      select: [p.name, c.type, c.content],
      where: c.type == "email",
      order_by: p.name
    )
    assert UQuery.Counter.count(UQuery.Repo, query) == 15
  end

  test "paginate/1 returns 2 pages when per_page is 20 and total is 37" do
    people = load_people(37)

    query = from(p in UQuery.Person, select: p)
    {items, metadata} = UQuery.Paginator.paginate(UQuery.Repo, query, 1, 20)

    assert items == Enum.slice(people, 0..19)
    assert metadata[:count] == 37
    assert metadata[:page] == 1
    assert metadata[:per_page] == 20
    assert metadata[:first] == 1
    assert metadata[:last] == 2
    assert metadata[:prev] == nil
    assert metadata[:next] == 2
    assert metadata[:serie] == [1, 2]
  end

  test "paginate/1 returns 4 pages when per_page is 10 and total is 37" do
    people = load_people(37)

    query = from(p in UQuery.Person, select: p)
    {items, metadata} = UQuery.Paginator.paginate(UQuery.Repo, query, 1, 10)

    assert items == Enum.slice(people, 0..9)
    assert metadata[:count] == 37
    assert metadata[:page] == 1
    assert metadata[:per_page] == 10
    assert metadata[:first] == 1
    assert metadata[:last] == 4
    assert metadata[:prev] == nil
    assert metadata[:next] == 2
    assert metadata[:serie] == [1, 2, 3, 4]
  end

  test "paginate/1 returns empty list if there is not enough items to paginate" do
    people = load_people(10)

    query = from(p in UQuery.Person, select: p)
    {items, metadata} = UQuery.Paginator.paginate(UQuery.Repo, query, 1, 10)

    assert items == people
    assert metadata[:count] == 10
    assert metadata[:page] == 1
    assert metadata[:first] == 1
    assert metadata[:last] == 1
    assert metadata[:prev] == nil
    assert metadata[:next] == nil
    assert metadata[:serie] == []
  end

  test "pagination/1 returns query with pagination and the pagination metadata" do
    _people = load_people(40)

    regular_query = from(p in UQuery.Person, select: p)
    {paginated_query, metadata} = UQuery.Paginator.pagination(UQuery.Repo, regular_query, 1, 20)

    # IO.inspect(paginated_query)
    assert %Ecto.Query{} = paginated_query
    assert metadata[:count] == 40
    assert metadata[:page] == 1
    assert metadata[:per_page] == 20
    assert metadata[:first] == 1
    assert metadata[:last] == 2
    assert metadata[:prev] == nil
    assert metadata[:next] == 2
    assert metadata[:serie] == [1, 2]
  end

  test "new/1 returns a serie with ellipsis at the end" do
    people = load_people(200)

    query = from(p in UQuery.Person, select: p)
    {items, metadata} = UQuery.Paginator.paginate(UQuery.Repo, query, 1, 20)

    assert items == Enum.slice(people, 0..19)
    assert metadata[:count] == 200
    assert metadata[:per_page] == 20
    assert metadata[:page] == 1
    assert metadata[:first] == 1
    assert metadata[:last] == 10
    assert metadata[:prev] == nil
    assert metadata[:next] == 2
    assert metadata[:serie] == [1, 2, 3, 4, 5, 6, 7, "...", 10]
  end

  test "new/1 returns a serie with ellipsis at the beginning" do
    people = load_people(200)

    query = from(p in UQuery.Person, select: p)
    {items, metadata} = UQuery.Paginator.paginate(UQuery.Repo, query, 10, 20)

    assert items == Enum.slice(people, 180..199)
    assert metadata[:count] == 200
    assert metadata[:per_page] == 20
    assert metadata[:page] == 10
    assert metadata[:first] == 1
    assert metadata[:last] == 10
    assert metadata[:prev] == 9
    assert metadata[:next] == nil
    assert metadata[:serie] == [1, "...", 4, 5, 6, 7, 8, 9, 10]
  end

  test "new/1 returns a serie with ellipsis at the beginning and at the end" do
    people = load_people(800)

    query = from(p in UQuery.Person, select: p)
    {items, metadata} = UQuery.Paginator.paginate(UQuery.Repo, query, 20, 20)

    assert items == Enum.slice(people, 380..399)
    assert metadata[:count] == 800
    assert metadata[:per_page] == 20
    assert metadata[:page] == 20
    assert metadata[:first] == 1
    assert metadata[:last] == 40
    assert metadata[:prev] == 19
    assert metadata[:next] == 21
    assert metadata[:serie] == [1, "...", 17, 18, 19, 20, 21, 22, 23, "...", 40]
  end

  defp load_people(total) when is_integer(total) do
    Enum.map(
      1..total,
      fn x ->
        {_, person} = %UQuery.Person{}
        |> UQuery.Person.changeset(%{name: "Personal Name #{zero_padding(Integer.to_string(x))}"})
        |> UQuery.Repo.insert()
        person
      end
    )
  end

  defp load_contact_for_person(person, type, content) do
    {_, contact} = %UQuery.Contact{}
    |> UQuery.Contact.changeset(%{person_id: person.id, type: type, content: content})
    |> UQuery.Repo.insert()
    contact
  end

  defp zero_padding(value) when is_binary(value) do
    if String.length(value) < 5 do
      zero_padding("0#{value}")
    else
      value
    end
  end

end
