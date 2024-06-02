defmodule Database.DatingProfiles do
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
end
