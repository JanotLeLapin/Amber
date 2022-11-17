defmodule Game do
  @moduledoc """
  A GenServer that stores a single game
  """

  use GenServer

  @doc """
  Time that elapsed since the game started in milliseconds, or -1 if the game is not running
  """
  @spec time(pid()) :: integer()
  def time(pid) do
    start = pid |> GenServer.call({:get_start})

    if start == -1,
      do: -1,
      else: :os.system_time(:millisecond) - start
  end

  def start_link(id) do
    __MODULE__ |> GenServer.start_link(id)
  end

  def init(id),
    do: {
      :ok,
      %{
        "id" => id,
        "start" => -1,
        "players" => %{}
      }
    }

  @spec update_player(map(), String.t(), String.t(), function()) :: map()
  defp update_player(state, id, k, v) do
    players = state["players"]
    player = players |> Map.get(id)

    state
    |> Map.put(
      "players",
      players
      |> Map.put(
        id,
        player |> Map.put(k, v.(player))
      )
    )
  end

  def handle_cast({:start}, state) do
    new_state =
      if state["start"] == -1,
        do: state |> Map.put("start", :os.system_time(:millisecond)),
        else: state

    {:noreply, new_state}
  end

  def handle_cast({:add_player, id}, state) do
    new_state =
      if state["players"] |> Map.get(id) do
        state
      else
        players =
          state["players"]
          |> Map.put(id, %{
            "spec" => false,
            "meta" => %{}
          })

        state |> Map.put("players", players)
      end

    {:noreply, new_state}
  end

  def handle_cast({:update_player, id, data}, state) do
    player = state["players"][id]
    data = data |> Map.take(player |> Map.keys)
    new_player = Map.merge(player, data, fn k, v1, v2 ->
      case k do
        "meta" -> v1
        _ -> v2
      end
    end)

    {:noreply, state |> Map.put("players", state["players"] |> Map.put(id, new_player))}
  end
  def handle_cast({:update_player_meta, id, data}, state) do
    new_state =
      state |> update_player(id, "meta", fn player -> Map.merge(player["meta"], data) end)

    {:noreply, new_state}
  end

  def handle_cast({:delete_player, id}, state) do
    {_, players} = state["players"] |> Map.pop(id)
    {:noreply, state |> Map.put("players", players)}
  end

  def handle_call({:get_id}, _, state), do: {:reply, state["id"], state}
  def handle_call({:get_start}, _, state), do: {:reply, state["start"], state}
  def handle_call({:get_players}, _, state), do: {:reply, state["players"], state}
  def handle_call({:get_player, id}, _, state) do
    player = state["players"] |> Map.get(id)
    {:reply, player, state}
  end
end