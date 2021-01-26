defmodule Kundi.Game do
  @moduledoc false

  @area 10
  @dimensions Enum.to_list(1..@area)
  @walls [{5, 2}, {5, 4}, {5, 5}, {5, 6}, {5, 7}, {6, 5}, {7, 5}, {8, 5}]
  @default_names ["Jon", "Daenerys", "Arya", "Sansa", "Tyrion"]

  def get_map_details do
    %{
      dimensions: @dimensions,
      unwalkable_tiles: map_walls(),
      walkable_tiles: walkable_tiles(),
      players: []
    }
  end

  def coordinates, do: create_map(@dimensions, [])

  def map_walls do
    coordinates()
    |> Enum.filter(fn {x, y} ->
        x == 1 ||
        y == 1 ||
        x == @area ||
        y == @area ||
        {x, y} in @walls
      end)
  end

  def walkable_tiles, do: coordinates() -- map_walls()

  defp create_map([], values), do: values
  defp create_map([head | tails], values) do
    coordinates = create_coordinates(@dimensions, head, [])
    values = values ++ coordinates
    create_map(tails, values)
  end

  defp create_coordinates([], _x, values), do: values
  defp create_coordinates([head | tails], x, values) do
    values = values ++ [{x, head}]
    create_coordinates(tails, x, values)
  end

  def add_hero_actions([]), do: []
  def add_hero_actions(players) do
    enemies = get_enemies(players)
    player_position = get_hero_detail(players, :player_position)
    alive = get_hero_detail(players, :alive)
    get_possible_actions(player_position, walkable_tiles(), enemies, alive)
  end

  defp get_possible_actions(nil, _walkable_tiles, _enemies, _), do: []
  defp get_possible_actions(_coordinates, _walkable_tiles, _enemies, false), do: []
  defp get_possible_actions({x, y}, walkable_tiles, enemies, _alive) do
    surrounding_coordinates = get_surrounding_coordinates({x, y})
    enemy_positions = Enum.filter(enemies, &(&1[:player_position] in surrounding_coordinates and &1.alive))

    []
    |> append_if_possible({x - 1, y} in walkable_tiles, "U")
    |> append_if_possible({x + 1, y} in walkable_tiles, "D")
    |> append_if_possible({x, y - 1} in walkable_tiles, "L")
    |> append_if_possible({x, y + 1} in walkable_tiles, "R")
    |> append_if_possible(!Enum.empty?(enemy_positions), "A")
  end

  defp get_surrounding_coordinates(nil), do: []
  defp get_surrounding_coordinates({x, y}) do
   [{x + 1, y + 1}, {x + 1, y - 1}, {x - 1, y - 1}, {x - 1, y + 1}, {x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  defp append_if_possible(actions, true, action), do: actions ++ [action]
  defp append_if_possible(actions, _condition, _action), do: actions

  def generate_player_details(players, name) do
    name
    |> is_new_player?(players)
    |> generate_player(name)
    |> get_updated_players(players, name)
  end

  defp is_new_player?(nil, players) do
    players
    |> Enum.filter(&(&1))
    |> Enum.filter(&(&1[:player_name] in @default_names))
    |> Enum.empty?()
  end

  defp is_new_player?(name, players) do
    players
    |> Enum.filter(&(&1))
    |> Enum.filter(&(&1[:player_name] == name))
    |> Enum.empty?()
  end

  defp generate_player(false, _name), do: nil
  defp generate_player(true, name) do
    player_position = Enum.random(walkable_tiles())
    player_name = name || Enum.random(@default_names)

    %{
      player_position: player_position,
      player_name: player_name,
      status: "hero",
      alive: true
    }
  end

  def update_player_details([], _action, _name), do: []
  def update_player_details(players, action, name) do
    player = get_hero(players, name)
    player_position = update_player_position(player, action)
    player =
      player
      |> Map.put(:player_position, player_position)
      |> Map.put(:status, "hero")

    players
    |> Enum.filter(&(&1[:player_name] != name))
    |> update_player_status("enemy")
    |> Enum.concat([player])
  end

  defp update_player_position(%{player_position: {x, y}, alive: false}, _action), do: {x, y}
  defp update_player_position(%{player_position: {x, y}}, "U"), do: {x - 1, y}
  defp update_player_position(%{player_position: {x, y}}, "D"), do: {x + 1, y}
  defp update_player_position(%{player_position: {x, y}}, "L"), do: {x, y - 1}
  defp update_player_position(%{player_position: {x, y}}, "R"), do: {x, y + 1}
  defp update_player_position(%{player_position: {x, y}}, "A"), do: {x, y}
  defp update_player_position(_, ""), do: ""

  def get_enemies(players), do: Enum.filter(players, &(&1.status != "hero"))

  def get_enemy_positions(players) do
    players
    |> get_enemies()
    |> Enum.map(&(&1[:player_position]))
  end

  defp get_hero(players, ""), do: Enum.find(players, &(&1[:player_name] in @default_names))
  defp get_hero(players, name), do: Enum.find(players, &(&1[:player_name] == name))

  defp get_updated_players(nil, players, name) do
    name = get_hero_name(players, name)
    enemies =
      players
      |> Enum.filter(&(&1))
      |> Enum.filter(&(&1[:player_name] != name))
      |> update_player_status("enemy")

    players
    |> Enum.filter(&(&1[:player_name] == name))
    |> update_player_status("hero")
    |> Enum.concat(enemies)
  end

  defp get_updated_players(player_details, players, _name) do
    players = update_player_status(players, "enemy")
    players ++ [player_details]
  end

  defp get_hero_name(players, nil) do
    players
    |> Enum.map(&(&1[:player_name]))
    |> Enum.filter(&(&1 in @default_names))
    |> Enum.random()
  end
  defp get_hero_name(_players, name), do: name

  defp update_player_status(players, status) do
    Enum.map(players, &(add_status(&1, status)))
  end

  defp add_status([], _status), do: []
  defp add_status(player, status), do: Map.put(player, :status, status)

  def get_hero_detail(players, field) do
    players
    |> Enum.find(&(&1.status == "hero"))
    |> get_value(field)
  end

  def get_player_name(players, position) do
    players
    |> Enum.find(&(&1[:player_position] == position && &1.status != "hero"))
    |> get_value(:player_name)
  end

  def update_alive_status(players, enemies) do
    enemies = resurrect(enemies)
    enemy_names = Enum.map(enemies, &(&1[:player_name]))

    players
    |> Enum.filter(&(&1[:player_name] not in enemy_names))
    |> Enum.concat(enemies)
  end

  def get_value(nil, _field), do: nil
  def get_value(player, field), do: Map.get(player, field)

  def kill_enemy(players, "A") do
    hero_position = get_hero_detail(players, :player_position)
    surrounding_coordinates = get_surrounding_coordinates(hero_position)

    enemies =
      players
      |> get_killing_enemies()
      |> kill()

    players
    |> Enum.filter(&(&1[:player_position] not in surrounding_coordinates))
    |> Enum.concat(enemies)
  end
  def kill_enemy(players, _action), do: players

  def get_killing_enemies(players) do
    hero_position = get_hero_detail(players, :player_position)
    surrounding_coordinates = get_surrounding_coordinates(hero_position)

    Enum.filter(players, &(&1[:player_position] in surrounding_coordinates && &1.status != "hero"))
  end

  defp kill([]), do: %{}
  defp kill(enemies), do: Enum.map(enemies, &(Map.put(&1, :alive, false)))

  defp resurrect([]), do: []
  defp resurrect(players), do: Enum.map(players, &(Map.put(&1, :alive, true)))

end
