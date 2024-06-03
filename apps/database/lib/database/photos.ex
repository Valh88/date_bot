defmodule Database.Photos do
  import Ecto.Query
  alias Database.Profiles.Photo
  alias Database.Repo

  def save_photo(params) do
    %Photo{}
    |> Photo.changeset(params)
    |> Repo.insert()
  end

  def get_all_photos(dating_profile_id) do
    query =
      from(p in Photo,
        where: p.dating_profile_id == ^dating_profile_id,
        select: p.photo
      )

    Repo.all(query)
  end
end
