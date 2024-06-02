defmodule Middleware.UserProfileContext do
  use ExGram.Middleware
  alias ExGram.Cnt
  alias Database.Users
  alias Bot.DynamicSupervisor
  import ExGram.Dsl

  def call(%Cnt{update: update} = cnt, _opts) do
    {:ok, %{id: id}} = extract_user(update)
    user = Users.get_user_by_telega_id(id, :preload)
    cnt = add_extra(cnt, :user, user)
    
    DynamicSupervisor.start_child(user.id)

    unless user.dating_profile do
      if update.message.text == "/profile" do
        answer(cnt, "👋 Пора создать анкету!")
      else
        cnt
      end
    else
      cnt
    end
  end
end
