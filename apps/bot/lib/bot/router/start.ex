defmodule Bot.Router.Start do
  alias Database.Users
  import ExGram.Dsl
  alias Bot.Router.Lexicon

  @key1 [
    {"Смотреть анкеты", "show_dating_profiles"},
    {"Редактировать анкету", "edit_dating_profile"}
  ]

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
    data =
      Enum.reduce(@key1, [], fn {text, call}, acc ->
        [%{text: text, callback_data: call} | acc]
      end)

    # todo: add cache_time orm maybe not
    answer(context, "👤 Выберите действие:", reply_markup: create_inline([data]))
  end
end
