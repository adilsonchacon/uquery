defmodule UQuery.Migrations do
  @moduledoc """
  Migrates for setting up database when testing.
  """
  use Ecto.Migration

  def change do
    create table("people") do
      add(:name, :string)
      add(:birthday, :naive_datetime)

      timestamps()
    end

    create table("contacts") do
      add(:content, :string)
      add(:type, :string) # email or telephone
      add(:person_id, references(:people))

      timestamps()
    end
  end
end
