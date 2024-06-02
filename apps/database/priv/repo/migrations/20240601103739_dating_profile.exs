defmodule Database.Repo.Migrations.DatingProfile do
  use Ecto.Migration

  def change do
    create table(:dating_profiles) do
      add :name, :string
      add :age, :integer
      add :gender, :string
      add :description, :string
      add :user_id, references(:users, type: :id)
      # add :photos, {:array, :string} todo

      timestamps()
    end
  end
end
