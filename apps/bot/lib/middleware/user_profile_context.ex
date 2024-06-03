defmodule Middleware.UserProfileContext do
  use ExGram.Middleware
  alias ExGram.Cnt
  alias Database.Users
  alias Bot.DynamicSupervisor
  import ExGram.Dsl
  require Logger

  def call(%Cnt{update: update} = cnt, _opts) do
    {:ok, %{id: id}} = extract_user(update)
    user = Users.get_or_create_user(id)
    cnt = add_extra(cnt, :user, user)

    unless user.dating_profile do
      DynamicSupervisor.start_child(user.id)

      case update do
        %{message: %{text: "/profile"}} ->
          answer(cnt, "👋 Пора создать анкету!")

        _ ->
          cnt
      end
    else
      cnt
    end
  end
end
