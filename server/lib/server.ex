defmodule Server do
  use Application

  def start(_, _) do
    child_spec = [
      %{
        id: Games,
        start: {Games, :start_link, []},
        type: :supervisor
      },
      {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4200]}
    ]

    Supervisor.start_link(child_spec, strategy: :one_for_one)
  end

  defmodule Router do
    use Plug.Router

    plug(:match)

    plug(Plug.Parsers,
      parsers: [:json],
      pass: ["application/json"],
      json_decoder: Jason
    )

    plug(:dispatch)

    @spec send_json(term(), integer(), term()) :: term()
    defp send_json(conn, status, body) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, body |> Jason.encode!)
    end

    defp send_status(conn, status) do
      conn |> send_resp(status, "")
    end

    defp with_game(conn, id, fun) do
      game = id |> Games.get_game()
      if game,
        do: fun.(game),
        else: conn |> send_status(404)
    end

    get "/games" do
      games = Games.get_games()
      conn |> send_json(200, games)
    end

    post "/games" do
      {uuid, _} = Games.create_game()
      conn |> send_resp(200, uuid)
    end

    patch "/games/:id/start", do:
      conn |> with_game(id, fn game ->
        game |> Game.start_game
        conn |> send_status(200)
      end)

    get "/games/:id/time", do: conn |> with_game(id, fn game ->
      conn |> send_resp(200, game |> Game.time |> Integer.to_string)
    end)

    get "/games/:id/players", do: conn |> with_game(id, fn game ->
      conn |> send_json(200, game |> Game.get_players)
    end)

    post "/games/:gid/players/:pid", do: conn |> with_game(gid, fn game ->
      game |> Game.add_player(pid)
      conn |> send_status(201)
    end)

    put "/games/:gid/players/:pid", do: conn |> with_game(gid, fn game ->
      game |> GenServer.cast({:update_player, pid, conn.body_params})
      conn |> send_status(200)
    end)

    put "/games/:gid/players/:pid/meta", do: conn |> with_game(gid, fn game ->
      game |> Game.update_player_meta(pid, conn.body_params)
      conn |> send_status(200)
    end)

    match _ do
      conn |> send_status(400)
    end
  end
end