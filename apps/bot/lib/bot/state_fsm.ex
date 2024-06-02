defmodule Bot.StateFsm do
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

  def save_profile(state, {:name, name}) do
    IO.inspect(name)
    %Bot.StateFsm{state | name: name}
  end

  def save_profile(state, {:age, age}) do
    %Bot.StateFsm{state | age: age}
  end

  def save_profile(state, {:gender, gender}) do
    %Bot.StateFsm{state | gender: gender}
  end

  def save_profile(state, {:description, description}) do
    %Bot.StateFsm{state | description: description}
  end

  def save_profile(state, {:photos, photos}) do
    # %Bot.StateFsm{state | photo: [photo | state.photo]}
    %Bot.StateFsm{state | photos: photos}
  end
end
