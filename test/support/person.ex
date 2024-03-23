defmodule UQuery.Person do
  @moduledoc """
  Entity schema for people table in databse.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "people" do
    field :name, :string
    field :birthday, :naive_datetime

    has_many :contacts, UQuery.Contact

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :birthday])
    |> validate_required([:name])
  end
end
