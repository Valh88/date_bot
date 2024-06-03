defmodule Database.Repo.Migrations.CreatePhotosProfilesDating do
  use Ecto.Migration

  def change do
    create table(:photos_profiles_dating) do
      add :dating_profile_id, references(:dating_profiles, type: :id)
      add :photo, :string

      timestamps()
    end
  end
end
