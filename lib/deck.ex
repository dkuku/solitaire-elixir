defmodule Solitaire.Deck do
  @moduledoc """
      iex> deck = Solitaire.Deck.new
      iex> length(deck)
      52
      iex> Solitaire.Deck.shuffle(deck,1234) == deck
      false
      iex> Solitaire.Deck.shuffle(deck,1234) == Solitaire.Deck.shuffle(deck,1234)
      true
      iex> Solitaire.Deck.shuffle(deck,1234) == Solitaire.Deck.shuffle(deck,12345)
      false

  """
  alias Solitaire.Cards

  @type t :: [Cards.t()]

  @spec new :: Deck.t()
  @doc "Create a deck of all possible cards"
  def new do
    for suit <- Cards.suits(), value <- Cards.values() do
      Cards.new(suit, value)
    end
  end

  @spec shuffle(Deck.t(), integer) :: Deck.t()
  @doc "Shuffle a Deck based on a key. If you use the same key, you get the same randomized Deck"
  def shuffle(deck, key) do
    :rand.seed(:exsplus, {1, 2, key})
    Enum.shuffle(deck)
  end
end
