defmodule Bot.Router.DatingProfile do
  alias Database.DatingProfiles
  alias ExGram.Dsl
  
  def create_dating_profile(params) do
    DatingProfiles.create_dating_profile(params)
  end


end
