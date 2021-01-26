defmodule Kundi.GameTest do
  use Kundi.DataCase

  alias Kundi.Game

  setup do
    players1 = [%{
      player_position: {3, 3},
      player_name: "Joeffrey",
      status: "hero",
      alive: true
    }]

    players2 = [%{
      player_position: {3, 3},
      player_name: "Joeffrey",
      status: "hero",
      alive: true
    },
    %{
      player_position: {3, 4},
      player_name: "Geralt",
      status: "hero",
      alive: true
    }]

    players3 = [%{
      player_position: {3, 3},
      player_name: "Joeffrey",
      status: "hero",
      alive: true
    },
    %{
      player_position: {3, 4},
      player_name: "Geralt",
      status: "enemy",
      alive: true
    },
    %{
      player_position: {3, 2},
      player_name: "Tyrion",
      status: "enemy",
      alive: true
    }]

    {:ok, %{players1: players1, players2: players2, players3: players3}}
  end

  test "test add_hero_actions(list of players1)", %{players1: players1} do
    assert Game.add_hero_actions(players1) == ["U", "D", "L", "R"]
  end

  test "test generate_player_details(new_player)", %{players1: players1} do
    name = "Tyrion"
    players1 = Game.generate_player_details(players1, name)
    assert Enum.find(players1, &(&1.player_name == name))[:player_name] == name
  end

  test "test generate_player_details(existing_player, hero_name)", %{players1: players1} do
    players1 = Game.generate_player_details(players1, "Joeffrey")
    assert Enum.count(players1) == 1
  end

  test "test update_player_details(players1, action, hero_name) UP", %{players1: players1} do
    players1 = Game.update_player_details(players1, "U", "Joeffrey")
    assert Enum.at(players1, 0).player_position == {2, 3}
  end

  test "test update_player_details(players1, action, hero_name) DOWN", %{players1: players1} do
    players1 = Game.update_player_details(players1, "D", "Joeffrey")
    assert Enum.at(players1, 0).player_position == {4, 3}
  end

    test "test update_player_details(players1, action, hero_name) LEFT", %{players1: players1} do
    players1 = Game.update_player_details(players1, "L", "Joeffrey")
    assert Enum.at(players1, 0).player_position == {3, 2}
  end

  test "test update_player_details(players1, action, hero_name) RIGHT", %{players1: players1} do
    players1 = Game.update_player_details(players1, "R", "Joeffrey")
    assert Enum.at(players1, 0).player_position == {3, 4}
  end

  test "test update_player_details(players1, action, hero_name) ATTACK", %{players2: players2} do
    players = Game.update_player_details(players2, "A", "Joeffrey")

    number_of_initial_enemies =
      players2
      |> Enum.filter(&(&1.status == "enemy"))
      |> Enum.count()

    number_of_enemies =
      players
      |> Enum.filter(&(&1.status == "enemy"))
      |> Enum.count()

    assert number_of_initial_enemies == 0
    assert number_of_enemies == 1
  end

  test "test get_killing_enemies(players)", %{players3: players3} do
    enemies = Game.get_killing_enemies(players3)
    number_of_enemies =
      enemies
      |> Enum.filter(&(&1.status == "enemy"))
      |> Enum.count()
    assert number_of_enemies == 2
  end

  test "test kill_enemy(players, action)", %{players3: players3} do
    enemies = Game.kill_enemy(players3, "A")
    number_of_alive =
      enemies
      |> Enum.filter(&(&1.alive))
      |> Enum.count()

    assert number_of_alive == 1
  end

  test "test update_alive_status(players, action)", %{players3: players3} do
    enemies = Game.get_killing_enemies(players3)
    players = Game.kill_enemy(players3, "A")

    number_of_alive =
      players
      |> Enum.filter(&(&1.alive))
      |> Enum.count()

    assert number_of_alive == 1

    players = Game.update_alive_status(players, enemies)

    number_of_alive =
      players
      |> Enum.filter(&(&1.alive))
      |> Enum.count()

    assert number_of_alive == 3
  end

end
