defmodule Kundi do
  @moduledoc false

  use GenServer

  @name MyGame

  alias Kundi.Game

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  @impl GenServer
  def init(:ok) do
    {:ok, []}
  end

  @impl GenServer
  def handle_cast({:get_player_details, name}, players) do
    players = Game.generate_player_details(players, name)
    {:noreply, players}
  end

  @impl GenServer
  def handle_cast({:update_player_details, action, name}, players) do
    players = Game.update_player_details(players, action, name)
    {:noreply, players}
  end

  @impl GenServer
  def handle_call({:view, action}, _from, players) do
    actions = Game.add_hero_actions(players)
    enemies = Game.get_killing_enemies(players)
    players = Game.kill_enemy(players, action)
    update_alive(enemies, action)

    game_details =
      Game.get_map_details()
      |> Map.put(:actions, actions)
      |> Map.put(:players, players)

    {:reply, game_details, players}
  end

  @impl GenServer
  def handle_info({:update_alive, enemies}, players) do
    players = Game.update_alive_status(players, enemies)
    {:noreply, players}
  end

  def get_player_details(name) do
    GenServer.cast(@name, {:get_player_details, name})
  end

  def update_player_details(action, name) do
    GenServer.cast(@name, {:update_player_details, action, name})
  end

  def view_map_details(_reply, action) do
    GenServer.call(@name, {:view, action})
  end

  defp update_alive(enemies, "A"), do: Process.send_after(self(), {:update_alive, enemies}, 5 * 1000)
  defp update_alive(_enemies, _), do: ""
end
