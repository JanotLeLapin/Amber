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
    start = pid |> GenServer.call({:get, "start"})

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
            "spec" => false
          })

        state |> Map.put("players", players)
      end

    {:noreply, new_state}
  end

  def handle_cast({:update, k, v}, state) when k not in ~w(id start players),
    do: {:noreply, state |> Map.put(k, v)}

  def handle_cast({:update_player, id, k, v}, state) do
    player = state["players"][id] |> Map.put(k, v)
    {:noreply, state |> Map.put("players", state["players"] |> Map.put(id, player))}
  end

  def handle_cast({:delete_player, id}, state) do
    {_, players} = state["players"] |> Map.pop(id)
    {:noreply, state |> Map.put("players", players)}
  end

  def handle_call({:get, k}, _, state), do: {:reply, state[k], state}
  def handle_call({:get_players}, _, state), do: {:reply, state["players"] |> Map.keys(), state}

  def handle_call({:player_exists, id}, _, state),
    do: {:reply, state["players"] |> Map.has_key?(id), state}

  def handle_call({:get_player, id, k}, _, state),
    do: {:reply, state["players"] |> Map.get(id) |> Map.get(k), state}
end
