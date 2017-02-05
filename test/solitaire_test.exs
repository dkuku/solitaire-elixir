defmodule SolitaireTest do
  use ExUnit.Case
  doctest Solitaire

  test "there are four suits" do
    assert length(Solitaire.Cards.suits) == 4
  end

  test "there are 13 values" do
    assert length(Solitaire.Cards.values) == 13
  end

  test "create some cards" do
    card = Solitaire.Cards.new(:hearts,12)

    assert Solitaire.Cards.suit_of(card) == :hearts
    assert Solitaire.Cards.value_of(card) == 12
  end
end
