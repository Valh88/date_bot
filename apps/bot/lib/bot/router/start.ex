defmodule Bot.Router.Start do
  alias Database.Users

  def check_user(telega_id) do
    Users.get_user_by_telega_id(telega_id, :preload)
  end
end
