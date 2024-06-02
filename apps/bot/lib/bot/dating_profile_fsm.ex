defmodule Bot.DatingProfileFsm do
  use GenStateMachine
  alias Bot.StateFsm

  def start_link(name) do
    GenStateMachine.start_link(__MODULE__, %{}, name: via_tuple(name))
  end

  def init(_) do
    {:ok, :wait_name, StateFsm.new()}
  end

  def handle_event({:call, from}, {:name, name}, :wait_name, _state) do
    state = %StateFsm{name: name}
    {:next_state, :wait_age, state, [{:reply, from, :ok}]}
  end

  def handle_event({:call, from}, {:age, age}, :wait_age, state) do
    {:next_state, :wait_gender, StateFsm.save_profile(state, {:age, age}), {:reply, from, :ok}}
  end

  def handle_event({:call, from}, {:gender, gender}, :wait_gender, state) do
    {:next_state, :wait_description, StateFsm.save_profile(state, {:gender, gender}), {:reply, from, :ok}}
  end

  def handle_event({:call, from}, {:description, description}, :wait_description, state) do
    {:next_state, :wait_photo, StateFsm.save_profile(state, {:description, description}), {:reply, from, :ok}}
  end

  def handle_event({:call, from}, {:photos, photos}, :wait_photo, state) do
    state = StateFsm.save_profile(state, {:photos, photos})
    {:next_state, :save_profile, state, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, :save_profile, :save_profile, state) do
    {:next_state, :exit, state, {:reply, from, {:ok, state}}}
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

  def via_tuple(name) do
    {:via, Registry, {Bot.Registry, name}}
  end
end
