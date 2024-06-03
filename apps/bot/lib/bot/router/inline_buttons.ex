defmodule Bot.Router.InlineButtons do
  import ExGram.Dsl

  def male_female_choice do
    [
      %{
        text: "Male",
        callback_data: "male"
      },
      %{
        text: "Female",
        callback_data: "female"
      }
    ]
    |> create_inline()
  end
end
