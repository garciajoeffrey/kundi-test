defmodule KundiWeb.GameView do
  use KundiWeb, :view

  def get_position_details(%{players: []}, _coordinates), do: tile_status("", "")
  def get_position_details(%{players: players}, coordinates) do
    players
    |> Enum.filter(&(&1[:player_position] == coordinates))
    |> check_if_player()
  end

  defp check_if_player([]), do: tile_status("", "")
  defp check_if_player([player | []]), do: get_status(player)
  defp check_if_player(players) do
    players
    |> check_if_hero()
    |> check_if_enemy(players)
    |> get_status()
  end

  defp check_if_hero(players) do
    players
    |> Enum.find(&(&1[:status] == "hero"))
  end

  defp check_if_enemy(nil, players), do: List.first(players)
  defp check_if_enemy(player, _players), do: player

  defp get_status(%{status: status, alive: true, player_name: name}), do: tile_status(status, name)
  defp get_status(%{player_name: name}), do: tile_status("", name)

  defp tile_status(status, name), do: %{status: status, name: name}

  def generate_route(conn, route, action, %{players: players}) do
    Routes.game_path(conn, route, action: action, name: get_hero_name(players))
  end

  def get_hero_name(players) do
    players
    |> Enum.find(&(&1[:status] == "hero"))
    |> get_value(:player_name)
  end

  def get_value(nil, _field), do: nil
  def get_value(player, field), do: Map.get(player, field)

  def check_player_move(%{actions: actions}, action), do: action in actions
end
