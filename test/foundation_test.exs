defmodule FoundationTest do
  use ExUnit.Case

  alias Solitaire.Cards, as: Cards
  alias Solitaire.Foundation, as: Foundation

  doctest Foundation

  test "A new Foundation is empty" do
    foundation = Foundation.new()

    assert length(Foundation.up(foundation)) == 0
  end

  test "Can drop an Ace on an empty Foundation" do
    foundation = Foundation.new()

    for suit <- Cards.suits() do
      assert Foundation.can_drop?(foundation, Cards.new(suit, 1))
    end
  end

  test "Drop an Ace onto an empty Foundation => Ace becomes top card" do
    foundation = Foundation.drop(Foundation.new(), Cards.new(:hearts, 1))

    assert Foundation.up(foundation) == [Cards.new(:hearts, 1)]
  end

  test "Can drop cards onto foundation when same suit and following value" do
    foundation = Foundation.drop(Foundation.new(), Cards.new(:hearts, 1))

    Enum.reduce(2..13, foundation, fn value, foundation ->
      card = Cards.new(:hearts, value)
      assert Foundation.can_drop?(foundation, card)
      Foundation.drop(foundation, card)
    end)
  end
end
