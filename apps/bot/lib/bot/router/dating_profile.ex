defmodule Bot.Router.DatingProfile do
  alias Database.DatingProfiles

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
end
