defmodule Solitaire.Foundation do
  @moduledoc """
  A Foundation has zero or more cards facing up with the same suit and increasing values

  ## Examples

      iex> foundation = Solitaire.Foundation.new
      iex> length(Solitaire.Foundation.up(foundation))
      0


  """

  @opaque foundation :: [ Solitaire.Cards.t ]
  @type t :: foundation

  @spec new :: Solitaire.Foundation.t
  @doc "Create a new empty Foundation"
  def new do
    []
  end

  @spec up(Solitaire.Foundation.t) :: [ Solitaire.Cards.t ]
  @doc "The list of up cards in the Foundation"
  def up(foundation) do
    foundation
  end

  @spec can_drop?(Solitaire.Foundation.t,Solitaire.Cards.t) :: boolean
  @doc "Can drop an Ace on an ampty Foundation or a card on another if the same suit and value one higher"
  def can_drop?([],card) do
    Solitaire.Cards.value_of(card) == 1
  end

end