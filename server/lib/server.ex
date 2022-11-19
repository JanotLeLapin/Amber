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
    plug(:dispatch)

    @spec send_json(term(), integer(), term()) :: term()
    defp send_json(conn, status, body) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, body |> Jason.encode!())
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

    defp with_player(conn, gid, pid, fun),
      do:
        conn
        |> with_game(gid, fn game ->
          if game |> GenServer.call({:player_exists, pid}),
            do: fun.(game),
            else: conn |> send_status(404)
        end)

    defp parse_body!(conn) do
      {:ok, body, conn} = conn |> Plug.Conn.read_body()
      {body |> Jason.decode!() |> Map.get("v"), conn}
    end

    get "/games" do
      games = Games.get_games()
      conn |> send_json(200, games)
    end

    post "/games" do
      {uuid, _} = Games.create_game()
      conn |> send_resp(200, uuid)
    end

    patch("/games/:id/time",
      do:
        conn
        |> with_game(id, fn game ->
          game |> GenServer.cast({:start})
          conn |> send_status(200)
        end)
    )

    get("/games/:id/time",
      do:
        conn
        |> with_game(id, fn game ->
          conn |> send_resp(200, game |> Game.time() |> Integer.to_string())
        end)
    )

    delete("/games/:id",
      do:
        conn
        |> with_game(id, fn game ->
          game |> Games.delete_game()
          conn |> send_status(200)
        end)
    )

    get("/games/:id/players",
      do:
        conn
        |> with_game(id, fn game ->
          conn |> send_json(200, game |> GenServer.call({:get_players}))
        end)
    )

    get("/games/:gid/players/:pid/:key",
      do:
        conn
        |> with_player(gid, pid, fn game ->
          conn
          |> send_resp(
            200,
            %{
              "v" => game |> GenServer.call({:get_player, pid, key})
            }
            |> Jason.encode!()
          )
        end)
    )

    post("/games/:gid/players",
      do:
        conn
        |> with_game(gid, fn game ->
          {:ok, body, conn} = conn |> Plug.Conn.read_body()

          if game |> GenServer.call({:player_exists, body}) do
            conn |> send_status(403)
          else
            game |> GenServer.cast({:add_player, body})
            conn |> send_status(201)
          end
        end)
    )

    put("/games/:gid/players/:pid/:key",
      do:
        conn
        |> with_player(gid, pid, fn game ->
          {body, conn} = conn |> parse_body!
          game |> GenServer.cast({:update_player, pid, key, body})
          conn |> send_status(200)
        end)
    )

    delete("/games/:gid/players/:pid",
      do:
        conn
        |> with_player(gid, pid, fn game ->
          game |> GenServer.cast({:delete_player, pid})
          conn |> send_status(200)
        end)
    )

    match _ do
      conn |> send_status(400)
    end
  end
end
