defmodule Database.Profiles.Photo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Database.Profiles.DatingProfile

  schema "photos_profiles_dating" do
    belongs_to(:dating_profile, DatingProfile)
    field(:photo, :string)

    timestamps()
  end

  def changeset(photo, params \\ %{}) do
    photo
    |> cast(params, [:dating_profile_id, :photo])
    |> validate_required([:dating_profile_id, :photo])
  end
end
