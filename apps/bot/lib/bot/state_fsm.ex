defmodule Bot.StateFsm do
  require Logger
  alias Database.DatingProfiles
  alias Database.Photos

  defstruct [:user_id, :name, :age, :gender, :description, photos: []]

  @type t :: %Bot.StateFsm{
          name: String.t(),
          age: integer(),
          gender: String.t(),
          description: String.t(),
          photos: list(String.t())
        }

  # @type gender :: "male" | "female"
  @valid_length_description 4
  @valid_length_name 3
  @valid_length_photos 2
  @valid_age_min 2
  @valid_age_max 120
  @valid_gender ["male", "female"]

  def new(user_id) do
    %Bot.StateFsm{user_id: user_id}
  end

  def valid_photos do
    @valid_length_photos
  end

  def save_profile(state, {key, value}) when is_struct(state, Bot.StateFsm) do
    new_state =
      case key do
        :name -> valid_name(state, value)
        :age -> valid_age(state, value)
        :gender -> valid_gender(state, value)
        :description -> valid_description(state, value)
        :photos -> valid_photos(state, value)
      end

    new_state
  end

  def save_profile_in_db(state) do
    {:ok, profile} = DatingProfiles.create_dating_profile(%{
      user_id: state.user_id,
      name: state.name,
      age: state.age,
      gender: state.gender,
      description: state.description,
    })
    Enum.each(state.photos, fn photo ->
      Photos.save_photo(%{dating_profile_id: profile.id, photo: photo})
    end)
  end

  defp valid_name(state, name) when is_binary(name) do
    if String.length(name) > @valid_length_name do
      %Bot.StateFsm{state | name: String.capitalize(name)}
    else
      {:error, "Name must be at least 3 characters long"}
    end
  end

  defp valid_age(state, age) do
    try do
      age = String.to_integer(age)

      if age >= @valid_age_min and age <= @valid_age_max do
        %Bot.StateFsm{state | age: age}
      else
        {:error, "Age must be between 18 and 120"}
      end
    rescue
      _ -> {:error, "Age must be an integer"}
    end
  end

  defp valid_gender(state, gender) when is_binary(gender) do
    if gender in @valid_gender do
      %Bot.StateFsm{state | gender: gender}
    else
      {:error, "male or female"}
    end
  end

  defp valid_description(state, description) when is_binary(description) do
    if String.length(description) > @valid_length_description do
      %Bot.StateFsm{state | description: description}
    else
      {:error, "Description must be at least 20 characters long"}
    end
  end

  defp valid_photos(state, photos) do
    Logger.debug("photos: #{inspect(photos)}")
    Logger.debug("state: #{inspect(state)}")
    Logger.debug("state.photos: #{inspect(state.photos)}")

    try do
      %Bot.StateFsm{state | photos: [photos | state.photos]}
    rescue
      _ -> {:error, "photo in list must be a string"}
    end
  end

  def save_profiles(%Bot.StateFsm{} = state) do
    profile = DatingProfiles.create_dating_profile(%{
      user_id: state.user_id,
      name: state.name,
      age: state.age,
      gender: state.gender,
      description: state.description,
      photos: state.photos
    })
  end
end
