defmodule Bot.StateFsm do
  require Logger

  defstruct [:name, :age, :gender, :description, :photos]

  @type t :: %Bot.StateFsm{
    name: String.t(),
    age: integer(),
    gender: String.t(),
    description: String.t(),
    photos: list(String.t())
  }

  def new() do
    %Bot.StateFsm{}
  end

  def save_profile(state, {key, value}) when is_struct(state, Bot.StateFsm) do
    Logger.debug("Current state: #{inspect(state)}")
    new_state =
      case key do
        :name -> %Bot.StateFsm{state | name: String.capitalize(value)}
        :age -> %Bot.StateFsm{state | age: value}
        :gender -> %Bot.StateFsm{state | gender: value}
        :description -> %Bot.StateFsm{state | description: String.capitalize(value)}
        :photos -> %Bot.StateFsm{state | photos: value}
      end
    Logger.debug("New state: #{inspect(new_state)}")
    new_state
  end

  def save_profile(state, {key, value}) do
    Logger.debug("Current state: #{inspect(state)}")
    Logger.debug("Key: #{inspect(key)}")
    Logger.debug("Value: #{inspect(value)}")
  end
end
