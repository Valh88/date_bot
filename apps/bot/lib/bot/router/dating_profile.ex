defmodule Bot.Router.DatingProfile do
  import ExGram.Dsl
  alias Database.DatingProfiles
  alias Bot.DatingProfileFsm
  alias Bot.Router.Lexicon
  alias Bot.Router.InlineButtons
  alias Bot.Router.Start
  alias Database.Photos
  require Logger

  def start_fsm_create_profile(context, user_id, text) do
    case DatingProfileFsm.get_current_context(user_id) do
      {:current, :wait_name} -> save_name(context, user_id, text)
      {:current, :wait_age} -> save_age(context, user_id, text)
      {:current, :wait_gender} -> save_gender(context, user_id, text)
      {:current, :wait_description} -> save_description(context, user_id, text)
      # to do
      {:current, :wait_photos} -> answer(context, Lexicon.need_save_photo_answer())
      {:current, :save_profile} -> answer(context, Lexicon.profile_be_saved())
      _ -> answer(context, "👤 Просто сообщение")
    end
  end

  def save_gender(context, user_id, gender) do
    case DatingProfileFsm.gender(user_id, gender) do
      {:ok, _new_state} ->
        answer(context, Lexicon.enter_description())

      {:error, error} ->
        answer(context, Lexicon.error(error))
    end
  end

  def profile(context, message_id, user) do
    Start.send_photo_group_with_caption(
      message_id,
      Photos.get_all_photos(user.dating_profile.id),
      user.dating_profile
    )

    answer_profile(context)
  end

  def handle_save_photo(context, user_id, photo_id) do
    case DatingProfileFsm.get_current_context(user_id) do
      {:current, :wait_photos} ->
        save_photos(context, user_id, photo_id)

      _ ->
        Logger.debug("state: #{inspect(DatingProfileFsm.get_current_context(user_id))}")
    end
  end

  def error_save_photo(context, user_id) do
    case DatingProfileFsm.get_current_context(user_id) do
      {:current, :wait_photos} ->
        answer(context, Lexicon.try_enter_photo())

      _ ->
        Logger.debug("state: #{inspect(DatingProfileFsm.get_current_context(user_id))}")
    end
  end

  def hendle_callback_query_by_profile_menu(context, callback_id, data) do
    case data do
      # todo
      "edit_dating_profile" -> menu_redact_profile(context, callback_id)
      # todo
      "restart_dating_profile" -> menu_redact_profile(context, callback_id)
      # todo
      "change_photo" -> menu_redact_profile(context, callback_id)
      # todo
      "change_description" -> menu_redact_profile(context, callback_id)
      # todo
      "delete_dating_profile" -> menu_redact_profile(context, callback_id)
      "cancel_profile" -> cancel_profile(context, callback_id)
    end
  end

  defp cancel_profile(context, callback_id) do
    ExGram.answer_callback_query(callback_id)
    edit(context, :inline, Lexicon.choice_do(), reply_markup: create_inline([Start.data()]))
  end

  defp save_name(context, user_id, name) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))
    state = DatingProfileFsm.name(user_id, name)
    Logger.debug("state: #{inspect(state)}")
    answer(context, Lexicon.enter_age())
  end

  defp save_age(context, user_id, age) do
    IO.inspect(DatingProfileFsm.get_current_context(user_id))

    case DatingProfileFsm.age(user_id, age) do
      {:ok, _new_state} ->
        answer(context, Lexicon.enter_gender(), reply_markup: InlineButtons.male_female_choice())

      {:error, error} ->
        answer(context, Lexicon.error(error))
    end
  end

  defp save_description(context, user_id, description) do
    case DatingProfileFsm.description(user_id, description) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_description: #{inspect(new_state)}")
        answer(context, Lexicon.send_photos())

      {:error, error} ->
        answer(context, Lexicon.error(error))
    end
  end

  defp save_photos(context, user_id, photos) do
    # todo: photos -> [photos]
    case DatingProfileFsm.photos(user_id, photos) do
      {:ok, new_state} ->
        Logger.debug("new_state_wait_photos: #{inspect(new_state)}")
        # to do
        DatingProfileFsm.save_full_state(user_id)
        answer(context, Lexicon.profile_be_saved())

      {:error, error} ->
        answer(context, Lexicon.error(error))
    end
  end

  defp menu_redact_profile(context, callback_id) do
    ExGram.answer_callback_query(callback_id)

    edit(context, :inline, Lexicon.choice_do(),
      reply_markup: InlineButtons.create_inline_menu_redact_profile()
    )
  end

  defp answer_profile(context) do
    answer(context, "profile", reply_markup: InlineButtons.create_inline_menu_redact_profile())
  end
end
