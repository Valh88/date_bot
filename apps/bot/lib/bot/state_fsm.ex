defmodule Bot.StateFsm do
  require Logger
  alias Bot.DatingProfileFsm
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

  def state_from_db(user_id) do
    case DatingProfiles.get_dating_profile_by_user_id(user_id) do
      profile when is_struct(profile) ->
        %Bot.StateFsm{
          user_id: user_id,
          name: profile.name,
          age: profile.age,
          gender: profile.gender,
          description: profile.description
          # photos: profile.photos
        }

      nil ->
        %Bot.StateFsm{user_id: user_id}
    end
  end

  def update_state_in_db(user_id, attrs) do
    DatingProfiles.update_dating_profile(user_id, attrs)
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
    {:ok, profile} =
      DatingProfiles.create_dating_profile(%{
        user_id: state.user_id,
        name: state.name,
        age: state.age,
        gender: state.gender,
        description: state.description
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

  defp valid_photos(state, photo) do

    case photo do
      photo when is_binary(photo) ->
        %Bot.StateFsm{state | photos: [photo | state.photos]}

      _ ->
        {:error, "photo in list must be a string"}
    end
  end

  def update_photos_profile(state, photos) do
    case valid_photos(state, photos) do
      %Bot.StateFsm{} = new_state ->
        if length(new_state.photos) <= @valid_length_photos do
          profile = DatingProfiles.get_dating_profile_by_user_id(state.user_id)
          Database.Repo.transaction(fn ->
            Photos.delete_all_photos(profile.id)
            Enum.each(new_state.photos, fn photo ->
              Photos.save_photo(%{dating_profile_id: new_state.user_id, photo: photo})
            end)
          end)
          new_state
        else
          DatingProfileFsm.stop(state.user_id)
          {:error, "You can send only no more #{@valid_length_photos} photos"}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  def save_profiles(%Bot.StateFsm{} = state) do
    DatingProfiles.create_dating_profile(%{
      user_id: state.user_id,
      name: state.name,
      age: state.age,
      gender: state.gender,
      description: state.description,
      photos: state.photos
    })
  end

  def delete_profile_in_db(user_id) do
    case DatingProfiles.get_dating_profile_by_user_id(user_id) do
      profile when is_struct(profile) ->
        Photos.delete_all_photos(profile.id)
        DatingProfiles.delete_dating_profile(profile)
        :ok

      nil ->
        {:error, "Profile not found"}
    end
  end
end
