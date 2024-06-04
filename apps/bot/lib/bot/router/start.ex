defmodule Bot.Router.Start do
  alias Database.Users
  import ExGram.Dsl
  alias Bot.Router.Lexicon
  alias Database.Photos

  @key1 [
    {Lexicon.see_dating_profile(), "show_dating_profiles"},
    {Lexicon.change_profile(), "edit_dating_profile"}
  ]

  def data do
    Enum.reduce(@key1, [], fn {text, call}, acc ->
      [%{text: text, callback_data: call} | acc]
    end)
  end

  def check_user(telega_id) do
    Users.get_user_by_telega_id(telega_id, :preload)
  end

  def send_photo_group_with_caption(chat_id, photos, caption) do
    media_group =
      Enum.with_index(photos, 1)
      |> Enum.map(fn {photo, index} ->
        if index == 1 do
          %ExGram.Model.InputMediaPhoto{
            media: photo,
            caption: Lexicon.start_dating_profile(caption),
            type: "photo"
          }
        else
          %ExGram.Model.InputMediaPhoto{
            media: photo,
            type: "photo"
          }
        end
      end)

    ExGram.send_media_group(chat_id, media_group)
  end

  def send_inline_keyboard(context) do
    # todo: add cache_time orm maybe not
    answer(context, Lexicon.choice_do(), reply_markup: create_inline([data()]))
  end

  def start(context, message_id, user) do
    IO.inspect(user.dating_profile)

    send_photo_group_with_caption(
      message_id,
      Photos.get_all_photos(user.dating_profile.id),
      user.dating_profile
    )

    send_inline_keyboard(context)
  end
end
