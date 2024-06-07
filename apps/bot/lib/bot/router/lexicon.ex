defmodule Bot.Router.Lexicon do
  def hello(locale) when is_binary(locale) do
    case locale do
      "en" -> "👋 Welcome, my personal assistant in finding a partner for you! You don't have a profile yet, click /profile to create it!"
      "ru" ->  hello()
      _ -> hello()
    end
  end

  def hello do
    "👋 Привет, я твой личный помощник в поиске партнера для тебя! У тебя еще нет анкеты, нажми /profile чтобы создать ее!"
  end

  def start_command_description do
    "👋 Стартовая"
  end

  def profile_command_description() do
    "👤 Моя анкета"
  end

  def dating_profile_command_description() do
    "👩‍👦‍👦 Смотреть анкеты"
  end

  def help_command_description() do
    "👤 Помощь"
  end

  def enter_name do
    "👤 Введите ваше имя, например: Вася"
  end

  def try_enter_photo do
    "👤 Отправте 2 или 3 фотографии группой"
  end

  def enter_age do
    "👤 Введите ваш возраст"
  end

  def enter_gender do
    "👤 Введите ваш пол"
  end

  def enter_description do
    "👤 Расскажите немного о себе"
  end

  def enter_photo do
    "👤 Отправьте фото"
  end

  def start_dating_profile(user_profile) do
    " Твоя анкета:
      Имя: #{user_profile.name}
      Возраст: #{user_profile.age}
      Пол: #{user_profile.gender}
      ------------------------------------
      Описание: #{user_profile.description}
    "
  end

  def change_profile do
    "👤 Редактировать анкету"
  end

  def see_dating_profile do
    "👩‍👦‍👦 Смотреть анкеты"
  end

  def choice_do do
    "👤 Выберите действие:"
  end

  def need_save_photo_answer do
    "👤 нужно отправить 2 или 3 фотографии"
  end

  def profile_be_saved do
    "👤 Анкета сохранена"
  end

  def send_photos do
    "👤 Отправьте фото"
  end

  def error(error) do
    "👤 Ошибка: #{error}"
  end

  def male do
    "Male"
  end

  def female do
    "Female"
  end

  def change_photo do
    "👤 Изменить фото"
  end

  def change_description do
    "👤 Изменить описание"
  end

  def restart_profile do
    "👤 Создать профиль заново"
  end

  def delete_profile do
    "👤 Удалить профиль"
  end

  def go_back do
    "👤 Вернуться назад"
  end

  def just_message do
    "👤 Просто сообщение"
  end

  def description_saved do
    "👤 Описание сохранено"
  end

  def profile_be_deleted do
    "👤 Профиль удален. Введите /profile чтобы создать новый."
  end
end
