defmodule Database.Profiles.DatingProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dating_profiles" do
    field(:name, :string)
    field(:age, :integer)
    field(:gender, :string)
    # field(:city, :string)
    field(:description, :string)
    # field :photos, {:array, :string} todo
    belongs_to(:user, User)

    timestamps()
  end

  def changeset(dating_profile, params \\ %{}) do
    dating_profile
    |> cast(params, [:name, :age, :gender, :description, :user_id])
    |> validate_required([:name, :age, :gender, :description, :user_id])
    |> validate_inclusion(:gender, ["male", "female"])
    |> validate_inclusion(:age, 1..60)
    |> validate_length(:description, max: 1000)
    |> validate_length(:name, max: 25)
  end
end
