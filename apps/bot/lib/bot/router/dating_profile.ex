defmodule Bot.Router.DatingProfile do
  import ExGram.Dsl
  alias Database.DatingProfiles
  alias Bot.DatingProfileFsm
  alias Bot.Router.Lexicon
  require Logger

  def create_dating_profile(params) do
    DatingProfiles.create_dating_profile(params)
  end

  def check_gender(gender) do
    case String.downcase(gender) do
      "male" -> "Male"
      "female" -> "Female"
      _ -> nil
    end
  end

  def stat_fsm_create_profile(context, user_id, text) do
    case DatingProfileFsm.get_current_context(user_id) do
      {:current, :wait_name} -> save_name(context, user_id, text)
      {:current, :wait_age} -> save_age(context, user_id, text)
      {:current, :wait_gender} -> save_gender(context, user_id, text)
      {:current, :wait_description} -> save_description(context, user_id, text)
      # to do
      {:current, :wait_photos} -> answer(context, "👤 нужно отправить 2 или 3 фотографии")
      {:current, :save_profile} -> answer(context, "👤 анкета сохранена")
      _ -> answer(context, "👤 Просто сообщение")
    end
  end

  def save_name(context, user_id, name) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))
    state = DatingProfileFsm.name(user_id, name)
    Logger.debug("state: #{inspect(state)}")
    answer(context, Lexicon.enter_age())
  end

  def save_age(context, user_id, age) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))

    case DatingProfileFsm.age(user_id, age) do
      {:ok, _new_state} ->
        markup =
          create_inline([
            [[text: "Male", callback_data: "male"], [text: "Female", callback_data: "female"]]
          ])

        answer(context, Lexicon.enter_gender(), reply_markup: markup)

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  def save_gender(context, user_id, gender) do
    case DatingProfileFsm.gender(user_id, gender) do
      {:ok, _new_state} ->
        answer(context, Lexicon.enter_description())

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  def save_description(context, user_id, description) do
    case DatingProfileFsm.description(user_id, description) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_description: #{inspect(new_state)}")
        answer(context, "👤 Отправьте фото")

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end

  def save_photos(context, user_id, photos) do
    # todo: photos -> [photos]
    case DatingProfileFsm.photos(user_id, photos) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_photos: #{inspect(new_state)}")
        # to do
        DatingProfileFsm.save_full_state(user_id)
        answer(context, "👤 анкета сохранена")

      {:error, error} ->
        answer(context, "👤 Ошибка: #{error}")
    end
  end
end
