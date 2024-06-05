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
    Repo.get_by(DatingProfile, user_id: user_id)
  end

  def get_dating_profile_by_user_id(user_id, :preload) do
    query =
      from(d in DatingProfile,
        where: d.id == ^user_id,
        preload: [:photos]
      )

    Repo.one(query)
  end

  def update_dating_profile(user_id, attrs) do
    get_dating_profile_by_user_id(user_id)
    |> DatingProfile.changeset(attrs)
    |> Repo.update()
  end

  def delete_dating_profile(profile) do
    profile
    |> Repo.delete()
  end
end
