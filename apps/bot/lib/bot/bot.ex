defmodule Bot.Bot do
  @bot :date_bot
  use ExGram.Bot, name: @bot, setup_commands: true
  require Logger
  alias ExGram.Cnt
  alias Bot.DatingProfileFsm
  alias Bot.Router.Start
  alias Bot.Router.DatingProfile
  alias Bot.Router.Lexicon

  command("start", description: Lexicon.start_command_description())
  command("profile", description: Lexicon.profile_command_description())
  command("dating", description: Lexicon.dating_profile_command_description())
  command("help", description: Lexicon.help_command_description())

  middleware(Middleware.UserProfileContext)

  def handle({:command, :start, msg}, %Cnt{extra: %{user: user}} = context) do
    if user.dating_profile do
      IO.inspect(user.dating_profile)

      Start.send_photo_group_with_caption(
        msg.chat.id,
        Database.Photos.get_all_photos(user.dating_profile.id),
        user.dating_profile
      )

      Start.send_inline_keyboard(context)
    else
      answer(
        context,
        Lexicon.hello()
      )
    end
  end

  def handle({:command, :profile, _msg}, %Cnt{extra: %{user: user}} = context) do
    IO.inspect(user.dating_profile)

    if user.dating_profile do
      answer(context, "profile")
    else
      answer(context, Lexicon.enter_name())
    end
  end

  def handle({:text, text, _msg}, %Cnt{extra: %{user: user}} = context) do
    Logger.debug("text: #{inspect(text)}")
    DatingProfile.stat_fsm_create_profile(context, user.id, text)
  end

  def handle(
        {:message, %ExGram.Model.Message{media_group_id: group_id, photo: photo}},
        %Cnt{extra: %{user: user}} = context
      )
      when not is_nil(group_id) and not is_nil(photo) do
    case DatingProfileFsm.get_current_context(user.id) do
      {:current, :wait_photos} ->
        DatingProfile.save_photos(context, user.id, hd(photo).file_id)

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
    DatingProfile.save_gender(context, user.id, data)
  end

  def handle(:callback_query, %{id: callback_id}, %Cnt{extra: %{user: _user}} = _context) do
    ExGram.answer_callback_query(callback_id, text: "👤 нерабочая кнопка")
  end
end
