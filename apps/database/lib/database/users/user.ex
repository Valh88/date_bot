defmodule Database.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Database.Profiles.DatingProfile

  schema "users" do
    field(:telega_id, :integer)
    has_one(:dating_profile, DatingProfile)
    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:telega_id])
    |> validate_required([:telega_id])
    |> unique_constraint(:telega_id)
  end
end
