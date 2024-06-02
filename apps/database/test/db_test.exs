defmodule DbTest do
  use ExUnit.Case
  alias Database.Users
  alias Database.DatingProfiles

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Database.Repo)
  end

  test "changeset test user" do
    user =
      Users.User.changeset(%Users.User{}, %{
        telega_id: 321
      })

    assert user.valid?
  end

  test "create user" do
    {:ok, user} = Users.create_user(%{telega_id: 321})

    {:ok, dating_profile} =
      DatingProfiles.create_dating_profile(%{
        user_id: user.id,
        name: "Test",
        age: 20,
        gender: "male",
        description: "Test"
      })

    user = Users.get_user_by_telega_id(321)
    assert user.telega_id == 321

    user = Users.get_user_by_telega_id(321, :preload)
    IO.inspect(user)
    user = Users.get_by_id(user.id)
    assert user.telega_id == 321
  end
end
