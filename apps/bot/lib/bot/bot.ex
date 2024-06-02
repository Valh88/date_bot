defmodule Bot.Bot do
  @bot :date_bot
  use ExGram.Bot, name: @bot, setup_commands: true
  require Logger
  alias ExGram.Cnt
  alias Bot.DatingProfileFsm

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

  def handle({:text, text, _msg}, %Cnt{extra: %{user: user}} = context) do
    IO.inspect(text)
    case DatingProfileFsm.get_current_context(user.id) do
      {:current, :wait_name} -> save_name(context, user.id, text)
      {:current, :wait_age} -> save_age(context, user.id, text)
      {:current, :wait_gender} -> save_gender(context, user.id, text)
      {:current, :wait_description} -> save_description(context, user.id, text)
      {:current, :save_photos} -> save_photos(context, user.id, text)
      {:current, :save_profile} -> Logger.debug("To do")
      _ -> answer(context, "👤 Просто сообщение")
    end
  end

  defp save_name(context, user_id, name) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))
    state = DatingProfileFsm.name(user_id, name)
    Logger.debug("state: #{inspect(state)}")
    answer(context, "👤 Введите ваш возраст")
  end


  defp save_age(context, user_id, age) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))
    DatingProfileFsm.age(user_id, age)
    answer(context, "👤 Введите ваш пол, например: male/female")
  end

  defp save_gender(context, user_id, gender) do
    DatingProfileFsm.gender(user_id, gender)
    answer(context, "👤 Введите немного о себе")
  end

  defp save_description(context, user_id, description) do
    DatingProfileFsm.description(user_id, description)
    answer(context, "👤 Отправьте фото")
  end

  defp save_photos(context, user_id, photos) do
    DatingProfileFsm.photos(user_id, photos)
    answer(context, "👤 анкета сохранена")
  end

  def handle(arg0, _arg1) do
    IO.inspect(arg0)
    # IO.inspect(arg1)
  end
end
