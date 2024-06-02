defmodule FsmTest do
  use ExUnit.Case
  alias Bot.DatingProfileFsm
  alias Bot.StateFsm
  require Logger
  doctest Bot.DatingProfileFsm

  setup do
    # Bot.Application.start()
    DatingProfileFsm.start_link("test")
    :ok
  end

  test "testing fsm", _context do
    state1 = %StateFsm{name: "test", age: 32, gender: "test", description: "test", photos: ["test"]}
    DatingProfileFsm.name("test", "test")
    DatingProfileFsm.age("test", 32)
    DatingProfileFsm.gender("test", "test")
    DatingProfileFsm.description("test", "test")
    DatingProfileFsm.photos("test", ["test"])

    {:ok, state} = DatingProfileFsm.get_full_state("test")
    assert state1.name == state.name
    assert state1.age == state.age
    assert state1.gender == state.gender
    assert state1.description == state.description
    assert state1.photos == state.photos
    Logger.info("State: #{inspect(state)}")
  end
end
