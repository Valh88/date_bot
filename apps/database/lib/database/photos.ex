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

  def delete_all_photos(profile_id) do
    query =
      from(p in Photo,
        where: p.dating_profile_id == ^profile_id
      )
    Repo.delete_all(query)
  end

  def update_photo(dating_profile_id, photo) do
    %Photo{}
    |> Photo.changeset(%{dating_profile_id: dating_profile_id, photo: photo})
    |> Repo.update()
  end

  def update_photos(dating_profile_id, photos) do
    Enum.map(photos, fn photo ->
      update_photo(dating_profile_id, photo)
    end)
  end
end
