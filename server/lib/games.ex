defmodule Games do
  @moduledoc """
  A GenServer that stores a reference for each game process
  """

  use DynamicSupervisor

  def start_link, do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def start_child do
  end

  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)

  @spec get_game(String.t()) :: pid() | nil
  def get_game(id) do
    game =
      __MODULE__
      |> DynamicSupervisor.which_children()
      |> Enum.find(fn {_, child, _, _} -> child |> Game.get_id() == id end)

    case game do
      nil -> nil
      {_, pid, _, _} -> pid
    end
  end

  @spec create_game :: {String.t(), pid()}
  def create_game do
    uuid = UUID.uuid4()
    {:ok, pid} = __MODULE__ |> DynamicSupervisor.start_child({Game, uuid})
    {uuid, pid}
  end

  @spec get_games() :: list(String.t())
  def get_games() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, child, _, _} -> child |> Game.get_id() end)
  end

  @spec find_player(String.t()) :: pid()
  def find_player(id) do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, child, _, _} -> child |> Game.get_player(id) end)
    |> Enum.find(fn player -> player end)
  end
end