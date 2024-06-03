defmodule Bot.Router.Lexicon do
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
end
