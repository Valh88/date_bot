defmodule Bot.Bot do
  @bot :date_bot
  use ExGram.Bot, name: @bot, setup_commands: true
  require Logger
  alias ExGram.Cnt
  alias Bot.Router.Start
  alias Bot.Router.DatingProfile
  alias Bot.Router.Lexicon

  command("start", description: Lexicon.start_command_description())
  command("profile", description: Lexicon.profile_command_description())
  command("dating", description: Lexicon.dating_profile_command_description())
  command("help", description: Lexicon.help_command_description())

  middleware(Middleware.UserProfileContext)

  @callback_profile_list [
    "restart_dating_profile",
    "change_photo",
    "change_description",
    "delete_dating_profile",
    "edit_dating_profile",
    "cancel_profile"
  ]

  defmacro data_in_callback_query?(data) do
    quote do
      # todo
      unquote(data) in unquote(@callback_profile_list)
    end
  end

  def handle({:command, :start, msg}, %Cnt{extra: %{user: user}} = context) do
    if user.dating_profile do
      Start.start(context, msg.chat.id, user)
    else
      answer(context, Lexicon.hello())
    end
  end

  def handle({:command, :profile, msg}, %Cnt{extra: %{user: user}} = context) do
    if user.dating_profile do
      DatingProfile.profile(context, msg.chat.id, user)
    else
      answer(context, Lexicon.enter_name())
    end
  end

  def handle({:text, text, _msg}, %Cnt{extra: %{user: user}} = context) do
    DatingProfile.start_fsm_create_profile(context, user.id, text)
  end

  def handle(
        {:message, %ExGram.Model.Message{media_group_id: group_id, photo: photo}},
        %Cnt{extra: %{user: user}} = context
      )
      when not is_nil(group_id) and not is_nil(photo) do
    DatingProfile.handle_save_photo(context, user.id, hd(photo).file_id)
  end

  def handle(
        {:message, %ExGram.Model.Message{media_group_id: _group_id, photo: photo}},
        %Cnt{extra: %{user: user}} = context
      )
      when not is_nil(photo) do
    DatingProfile.error_save_photo(context, user.id)
  end

  def handle(
        {:callback_query, %{id: callback_id, data: data}},
        %Cnt{extra: %{user: user}} = context
      )
      when data == "male" or data == "female" do
    ExGram.answer_callback_query(callback_id)
    DatingProfile.save_gender(context, user.id, data)
  end

  def handle(
        {:callback_query, %{id: callback_id, data: data}},
        %Cnt{extra: %{user: _user}} = context
      )
      when data_in_callback_query?(data) do
    DatingProfile.hendle_callback_query_by_profile_menu(context, callback_id, data)
  end

  def handle(:callback_query, %{id: callback_id}, %Cnt{extra: %{user: _user}} = _context) do
    ExGram.answer_callback_query(callback_id, text: "👤 нерабочая кнопка")
  end
end
