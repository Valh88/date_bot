defmodule Database.Repo.Migrations.UserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: true) do
      # add :id, :integer, primary_key: true
      add :telega_id, :integer
      
      timestamps()
    end
  end
end
