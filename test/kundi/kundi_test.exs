defmodule Kundi.Test do
  use Kundi.DataCase

  alias Kundi

  setup do
    GenServer.cast(MyGame, {:get_player_details, "Joeffrey"})

    {:ok, %{}}
  end

  describe "Tests for starting Kundi" do
    test "start_link/1 starts a GenServer(already started)" do
      pid = GenServer.whereis(MyGame)
      assert is_pid(pid)
    end

    test "init/1 returns {:ok, fresh_state}" do
      value = Kundi.init(:ok)
      assert value == {:ok, []}
    end
  end

  describe "handle tests" do
    test "Get game details to render" do
      game_details =
        MyGame
        |> GenServer.call({:view, "A"})
        |> Map.keys()

      assert game_details == [:actions, :dimensions, :players, :unwalkable_tiles, :walkable_tiles]
    end

    test "Add an existing player" do
      name = "Joeffrey"
      GenServer.cast(MyGame, {:get_player_details, name})

      player_count =
        MyGame
        |> GenServer.call({:view, ""})
        |> Map.get(:players)
        |> Enum.filter(&(&1.player_name == name))
        |> Enum.count()

      assert player_count == 1
    end

    test "Add a new player" do
      GenServer.cast(MyGame, {:get_player_details, "Geralt"})

      player_count =
        MyGame
        |> GenServer.call({:view, ""})
        |> Map.get(:players)
        |> Enum.map(&(&1.player_name))
        |> Enum.count()

      assert player_count == 2
    end

    test "Update player details LEFT" do
      {x, y} =
        MyGame
        |> GenServer.call({:view, ""})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      GenServer.cast(MyGame, {:update_player_details, "L", "Joeffrey"})

      {x2, y2} =
        MyGame
        |> GenServer.call({:view, "L"})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      assert {x, y - 1} == {x2, y2}
    end

    test "Update player details RIGHT" do
      {x, y} =
        MyGame
        |> GenServer.call({:view, ""})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      GenServer.cast(MyGame, {:update_player_details, "R", "Joeffrey"})

      {x2, y2} =
        MyGame
        |> GenServer.call({:view, "U"})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      assert {x, y + 1} == {x2, y2}
    end

    test "Update player details UP" do
      {x, y} =
        MyGame
        |> GenServer.call({:view, ""})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      GenServer.cast(MyGame, {:update_player_details, "U", "Joeffrey"})

      {x2, y2} =
        MyGame
        |> GenServer.call({:view, "U"})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      assert {x - 1, y} == {x2, y2}
    end

    test "Update player details DOWN" do
      {x, y} =
        MyGame
        |> GenServer.call({:view, ""})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      GenServer.cast(MyGame, {:update_player_details, "D", "Joeffrey"})

      {x2, y2} =
        MyGame
        |> GenServer.call({:view, "D"})
        |> Map.get(:players)
        |> Enum.find(&(&1.player_name == "Joeffrey"))
        |> Map.get(:player_position)

      assert {x + 1, y} == {x2, y2}
    end
  end

end
