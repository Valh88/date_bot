defmodule Bot.Bot do
  @bot :date_bot
  use ExGram.Bot, name: @bot, setup_commands: true
  require Logger
  alias ExGram.Cnt

  command("start", description: "👋 Стартовая")
  command("profile", description: "👤 Моя анкета")
  command("dating", description: "👩‍👦‍👦 Смотреть анкеты")
  command("help", description: "👉 Помощь")

  middleware(Middleware.UserProfileContext)

  def handle({:command, :start, _msg}, %Cnt{extra: %{user: user}} = context) do
    if user.dating_profile do
      answer(context, "profile")
    else
      answer(context, "👋 Привет, я твой личный помощник в поиске партнера для тебя! У тебя еще нет анкеты, нажми /profile чтобы создать ее!")
    end
  end

  def handle({:command, :profile, _msg}, %Cnt{extra: %{user: user}} = context) do
    if user.dating_profile do
      answer(context, "profile")
    else
      answer(context, "👤 Введите ваше имя, например: Вася")
    end
  end

  def handle({:text, text, _msg}, %Cnt{extra: %{user: _user}} = context) do
    IO.inspect(text)
    answer(context, text)
  end

  def handle(arg0, _arg1) do
    IO.inspect(arg0)
    # IO.inspect(arg1)
  end
end
