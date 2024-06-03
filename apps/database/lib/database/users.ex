defmodule Database.Users do
  alias Database.Repo
  alias Database.Users.User
  import Ecto.Query

  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def get_or_create_user(telega_id) do
    try do
      get_user_by_telega_id(telega_id, :preload)
    rescue
      _ ->
        {:ok, user} = create_user(%{telega_id: telega_id})
        get_user_by_telega_id(user.telega_id, :preload)
    end
  end

  def get_user_by_telega_id(telega_id) do
    Repo.get_by(User, telega_id: telega_id)
  end

  def get_user_by_telega_id(telega_id, :preload) do
    query =
      from(u in User,
        where: u.telega_id == ^telega_id,
        preload: :dating_profile
      )

    Repo.one!(query)
  end

  def get_by_id(id) do
    Repo.get(User, id)
  end
end
