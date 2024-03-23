defmodule UQuery.Contact do
  @moduledoc """
  Entity schema for contacts table in databse.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :type, :string
    field :content, :string

    belongs_to :person, UQuery.Person

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:type, :content, :person_id])
    |> validate_required([:type, :content, :person_id])
  end
end
