defmodule Solitaire do
  @moduledoc """
  Documentation for Solitaire.
  """
  use GenServer

  alias Solitaire.Deck
  alias Solitaire.Game

  @random_max 1_000_000
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def possible_moves(pid) do
    GenServer.call(pid, :possible_moves)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def reshuffle(pid) do
    GenServer.call(pid, :reshuffle)
  end

  def turn(pid) do
    GenServer.call(pid, :turn)
  end

  def perform(pid, move) do
    GenServer.call(pid, {:perform, move})
  end

  def init(opts) do
    seed = Keyword.get(opts, :seed, @random_max)

    game =
      Deck.new()
      |> Deck.shuffle(:rand.uniform(seed))
      |> Game.new()

    {:ok, game}
  end

  def handle_call(:get_state, _from, game) do
    {:reply, game, game}
  end

  def handle_call(:possible_moves, _from, game) do
    {:reply, Game.possible_moves(game), game}
  end

  def handle_call(:reshuffle, _from, game) do
    game = Game.reshuffle(game)
    {:reply, game, game}
  end

  def handle_call(:turn, _from, game) do
    game = Game.turn(game)
    {:reply, game, game}
  end

  def handle_call({:perform, move}, _from, game) do
    game = Game.perform(game, move)
    {:reply, game, game}
  end
end
