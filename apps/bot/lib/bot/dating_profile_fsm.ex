defmodule Bot.DatingProfileFsm do
  use GenStateMachine
  alias ElixirSense.Log
  alias Bot.StateFsm
  require Logger

  def start_link(name) do
    GenStateMachine.start_link(__MODULE__, %{}, name: via_tuple(name))
  end

  def init(_) do
    {:ok, :wait_name, StateFsm.new()}
  end

  def handle_event({:call, from}, {:name, name}, :wait_name, state) do
    Logger.debug("state_nam: #{inspect(state)}")
    Log
    new_state = StateFsm.save_profile(state, {:name, name})
    Logger.debug("new_state_wait_name: #{inspect(new_state)}")
    {:next_state, :wait_age, new_state, [{:reply, from, {:ok, new_state}}]}
  end

  def handle_event({:call, from}, {:age, age}, :wait_age, state) do
    new_state = StateFsm.save_profile(state, {:age, age})
    {:next_state, :wait_gender, new_state, {:reply, from, {:ok, new_state}}}
  end

  def handle_event({:call, from}, {:gender, gender}, :wait_gender, state) do
    new_state = StateFsm.save_profile(state, {:gender, gender})
    Logger.debug("state: #{inspect(state)}")
    Logger.debug("new_state: #{inspect(new_state)}")
    {:next_state, :wait_description, new_state, {:reply, from, {:ok, new_state}}}
  end

  def handle_event({:call, from}, {:description, description}, :wait_description, state) do
    new_state = StateFsm.save_profile(state, {:description, description})
    Logger.debug("new_state: #{inspect(state)}")
    {:next_state, :wait_photo, new_state, {:reply, from, {:ok, new_state}}}
  end

  def handle_event({:call, from}, {:photos, photos}, :wait_photo, state) do
    new_state = StateFsm.save_profile(state, {:photos, photos})
    Logger.debug("new_state: #{inspect(new_state)}")
    {:next_state, :save_profile, new_state, {:reply, from, new_state}}
  end

  def handle_event({:call, from}, :save_profile, :save_profile, state) do
    {:next_state, :exit, state, {:reply, from, {:ok, state}}}
  end

  def handle_event({:call, from}, :get_current_context, context, _state) do
    {:keep_state, context, {:reply, from, {:current, context}}}
  end

  def handle_event({:call, from}, _event, context, state) do
    {:keep_state, state, {:reply, from, {:error, {:next_state, context}}}}
  end

  def handle_info({:shutdown_message, msg}, state) do
    IO.puts(msg)
    {:stop, :normal, state}
  end

  def terminate(_reason, _state, _data) do
    send(self(), {:shutdown_message, "Машина состояний останавливается"})
    :ok
  end

  def stop(pid) do
    GenStateMachine.stop(via_tuple(pid), :shutdown)
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

  def get_full_state(pid) do
    GenStateMachine.call(via_tuple(pid), :save_profile)
  end

  def get_current_context(pid) do
    GenStateMachine.call(via_tuple(pid), :get_current_context)
  end

  def via_tuple(name) do
    {:via, Registry, {Bot.Registry, name}}
  end
end
