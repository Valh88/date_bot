defmodule Bot.Router.InlineButtons do
  import ExGram.Dsl
  alias Bot.Router.Lexicon

  @menu_redact [
    [
      [text: Lexicon.change_photo(), callback_data: "change_photo"],
      [text: Lexicon.change_description(), callback_data: "change_description"]
    ],
    [
      [text: Lexicon.restart_profile(), callback_data: "restart_dating_profile"],
      [text: Lexicon.delete_profile(), callback_data: "delete_dating_profile"]
    ],
    [
      [text: Lexicon.go_back(), callback_data: "cancel_profile"]
    ]
  ]

  def male_female_choice do
    [
      [
        [text: Lexicon.male(), callback_data: "male"],
        [text: Lexicon.female(), callback_data: "female"]
      ]
    ]
    |> create_inline()
  end

  def create_inline_menu_redact_profile do
    @menu_redact
    |> create_inline()
  end
end
