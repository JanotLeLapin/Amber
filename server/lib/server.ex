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
      conn |> send_status(status)
    end

    get "/games" do
      games = Games.get_games()
      conn |> send_json(200, games)
    end

    post "/games" do
      {uuid, _} = Games.create_game()
      conn |> send_resp(200, uuid)
    end

    patch "/games/:id/start" do
      game = Games.get_game(id)

      if game do
        game |> Game.start_game()
        conn |> send_status(200)
      else
        conn |> send_status(404)
      end
    end

    get "/games/:id/time" do
      game = Games.get_game(id)

      if game,
        do: conn |> send_resp(200, game |> Game.time() |> Integer.to_string()),
        else: conn |> send_status(404)
    end

    match _ do
      conn |> send_status(400)
    end
  end
end