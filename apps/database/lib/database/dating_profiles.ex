defmodule Database.DatingProfiles do
  import Ecto.Query
  alias Database.Repo
  alias Database.Profiles.DatingProfile

  def create_dating_profile(params) do
    %DatingProfile{}
    |> DatingProfile.changeset(params)
    |> Repo.insert()
  end

  def get_dating_profile_by_user_id(user_id) do
    Repo.get_by(DatingProfile, id: user_id)
  end

  def get_dating_profile_by_user_id(user_id, :preload) do
    query =
      from d in DatingProfile,
      where: d.id == ^user_id,
      preload: [:photos]

    Repo.one(query)
  end
end
