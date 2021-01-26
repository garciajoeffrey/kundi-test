defmodule KundiWeb.GameController do
  use KundiWeb, :controller

  def index(conn, params) do
    game_details =
      params["name"]
      |> Kundi.get_player_details()
      |> Kundi.view_map_details(params["action"])

    render(conn, "index.html", game_details: game_details)
  end

  def player_move(conn, params) do
    Kundi.update_player_details(params["action"], params["name"])
    redirect(conn, to: Routes.game_path(conn, :index, name: params["name"], action: params["action"]))
  end

end
