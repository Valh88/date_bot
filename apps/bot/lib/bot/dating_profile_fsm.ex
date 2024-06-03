defmodule Bot.DatingProfileFsm do
  use GenStateMachine
  alias Bot.StateFsm
  require Logger

  def start_link(name) do
    GenStateMachine.start_link(__MODULE__, %{user_id: name}, name: via_tuple(name))
  end

  def init(%{user_id: user_id}) do
    {:ok, :wait_name, StateFsm.new(user_id)}
  end

  def handle_event({:call, from}, {:name, name}, :wait_name, state) do
    Logger.debug("name: #{inspect(state)}")

    case StateFsm.save_profile(state, {:name, name}) do
      %Bot.StateFsm{} = new_state ->
        next_state(:wait_age, new_state, from)

      {:error, error} ->
        errors_return(state, from, error)
    end
  end

  def handle_event({:call, from}, {:age, age}, :wait_age, state) do
    case StateFsm.save_profile(state, {:age, age}) do
      %Bot.StateFsm{} = new_state ->
        next_state(:wait_gender, new_state, from)

      {:error, error} ->
        errors_return(state, from, error)
    end
  end

  def handle_event({:call, from}, {:gender, gender}, :wait_gender, state) do
    case StateFsm.save_profile(state, {:gender, gender}) do
      %Bot.StateFsm{} = new_state ->
        next_state(:wait_description, new_state, from)

      {:error, error} ->
        errors_return(state, from, error)
    end
  end

  def handle_event({:call, from}, {:description, description}, :wait_description, state) do
    case StateFsm.save_profile(state, {:description, description}) do
      %Bot.StateFsm{} = new_state ->
        next_state(:wait_photos, new_state, from)

      {:error, error} ->
        errors_return(state, from, error)
    end
  end

  def handle_event({:call, from}, {:photos, photos}, :wait_photos, state) do
    case StateFsm.save_profile(state, {:photos, photos}) do
      %Bot.StateFsm{} = new_state ->
        if length(new_state.photos) == StateFsm.valid_photos() do
          next_state(:save_profile, new_state, from)
        else
          next_state(:wait_photos, new_state, from)
        end

      {:error, error} ->
        errors_return(state, from, error)
    end
  end

  def handle_event({:call, _from}, :save_profile, :save_profile, state) do
    StateFsm.save_profile_in_db(state)
    send(self(), :shutdown)
    {:stop, :shutdown, state}
  end

  def handle_event({:call, from}, :get_current_context, context, state) do
    Logger.debug("state: #{inspect(state)}")
    {:keep_state, state, {:reply, from, {:current, context}}}
  end

  def handle_event({:call, from}, _event, context, state) do
    {:keep_state, state, {:reply, from, {:error, {:next_state, context}}}}
  end

  def handle_info(:shutdown, state) do
    GenStateMachine.stop(self(), :shutdown, 5000)
    {:stop, :shutdown, state}
  end

  def terminate(_reason, _state, _data) do
    send(self(), {:shutdown_message, "Машина состояний останавливается"})
    :ok
  end

  @spec stop(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: :ok
  def stop(pid) do
    GenStateMachine.stop(pid, :shutdown, 5000)
  end

  defp next_state(next, new_state, from) do
    {:next_state, next, new_state, {:reply, from, {:ok, new_state}}}
  end

  defp errors_return(state, from, error) do
    {:keep_state, state, {:reply, from, {:error, error}}}
  end

  def name(pid, name) do
    Logger.debug("name: #{inspect(name)}")
    GenStateMachine.call(via_tuple(pid), {:name, name})
  end

  def age(pid, age) do
    GenStateMachine.call(via_tuple(pid), {:age, age})
  end

  def gender(pid, gender) do
    GenStateMachine.call(via_tuple(pid), {:gender, gender})
  end

  def photos(pid, photos) do
    GenStateMachine.call(via_tuple(pid), {:photos, photos})
  end

  def description(pid, description) do
    GenStateMachine.call(via_tuple(pid), {:description, description})
  end

  def photo(pid, photo) do
    GenStateMachine.call(via_tuple(pid), {:photo, photo})
  end

  def save_full_state(pid) do
    GenStateMachine.call(via_tuple(pid), :save_profile)
  end

  def get_current_context(pid) do
    GenStateMachine.call(via_tuple(pid), :get_current_context)
  end

  defp via_tuple(name) do
    {:via, Registry, {Bot.Registry, name}}
  end
end
