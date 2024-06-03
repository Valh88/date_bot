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
      IO.inspect(user.dating_profile)
      answer(context, "profile")
    else
      answer(
        context,
        "👋 Привет, я твой личный помощник в поиске партнера для тебя! У тебя еще нет анкеты, нажми /profile чтобы создать ее!"
      )
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
    Logger.debug("text: #{inspect(text)}")

    case DatingProfileFsm.get_current_context(user.id) do
      {:current, :wait_name} -> save_name(context, user.id, text)
      {:current, :wait_age} -> save_age(context, user.id, text)
      {:current, :wait_gender} -> save_gender(context, user.id, text)
      {:current, :wait_description} -> save_description(context, user.id, text)
      # to do
      {:current, :wait_photos} -> answer(context, "👤 нужно отправить 2 или 3 фотографии")
      {:current, :save_profile} -> answer(context, "👤 анкета сохранена")
      _ -> answer(context, "👤 Просто сообщение")
    end
  end

  def handle(
        {:message, %ExGram.Model.Message{media_group_id: group_id, photo: photo}},
        %Cnt{extra: %{user: user}} = context
      )
      when not is_nil(group_id) and not is_nil(photo) do
    case DatingProfileFsm.get_current_context(user.id) do
      {:current, :wait_photos} ->
        save_photos(context, user.id, hd(photo).file_id)

      _ ->
        Logger.debug("state: #{inspect(DatingProfileFsm.get_current_context(user.id))}")
    end
  end

  def handle(
        {:callback_query, %{id: callback_id, data: data}},
        %Cnt{extra: %{user: user}} = context
      )
      when data == "male" or data == "female" do
    ExGram.answer_callback_query(callback_id)
    save_gender(context, user.id, data)
  end

  def handle(:callback_query, %{id: callback_id}, %Cnt{extra: %{user: _user}} = _context) do
    ExGram.answer_callback_query(callback_id, text: "👤 нерабочая кнопка")
  end

  defp save_name(context, user_id, name) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))
    state = DatingProfileFsm.name(user_id, name)
    Logger.debug("state: #{inspect(state)}")
    answer(context, "👤 Введите ваш возраст")
  end

  defp save_age(context, user_id, age) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))

    case DatingProfileFsm.age(user_id, age) do
      {:ok, _new_state} ->
        # answer(context, "👤 Введите ваш пол, например: male/female")
        markup =
          create_inline([
            [[text: "Male", callback_data: "male"], [text: "Female", callback_data: "female"]]
          ])

        answer(context, "👤 Выберите ваш пол, например: male/female", reply_markup: markup)

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  defp save_gender(context, user_id, gender) do
    case DatingProfileFsm.gender(user_id, gender) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_gender: #{inspect(new_state)}")
        answer(context, "👤 Расскажите немного о себе")

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  defp save_description(context, user_id, description) do
    case DatingProfileFsm.description(user_id, description) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_description: #{inspect(new_state)}")
        answer(context, "👤 Отправьте фото")

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  defp save_photos(context, user_id, photos) do
    # todo: photos -> [photos]
    case DatingProfileFsm.photos(user_id, photos) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_photos: #{inspect(new_state)}")
        # to do
        DatingProfileFsm.save_full_state(user_id)
        # Logger.debug("photos: #{DatingProfileFsm.stop(user_id)}")
        answer(context, "👤 анкета сохранена")

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  def handle(arg0, _arg1) do
    IO.inspect(arg0)
    # IO.inspect(arg1)
  end
end
