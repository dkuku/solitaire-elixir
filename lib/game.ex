defmodule Solitaire.Game do
  @moduledoc """
  A Solitaire Game

  ## Examples

      iex> deck = Solitaire.Deck.shuffle(Solitaire.Deck.new,1234)
      iex> game = Solitaire.Game.new(deck)
      iex> length(Solitaire.Game.tableaus(game))
      7
      iex> moves = Solitaire.Game.possible_moves(game)
      iex> moves
      [{:tableau, 3, :foundation, 0, {:diams, 1}},{:tableau, 6, :tableau, 4, {:spades, 2}},{:tableau, 3, :tableau, 6, {:diams, 1}}]
      iex> game = Solitaire.Game.perform(game,List.first(moves))
      iex> moves = Solitaire.Game.possible_moves(game)
      iex> moves
      [{:tableau, 6, :tableau, 4, {:spades, 2}}]
      iex> game = Solitaire.Game.perform(game,List.first(moves))
      iex> moves = Solitaire.Game.possible_moves(game)
      iex> moves
      []
      iex> game = Solitaire.Game.turn(game)
      iex> moves = Solitaire.Game.possible_moves(game)
      iex> moves
      [{:deck, 0, :tableau, 0, {:hearts, 7}}]

  """

  alias Solitaire.Cards, as: Cards
  alias Solitaire.Deck, as: Deck
  alias Solitaire.Foundation, as: Foundation
  alias Solitaire.Game, as: Game
  alias Solitaire.Stock, as: Stock
  alias Solitaire.Tableau, as: Tableau

  @typedoc "The state of the Solitaire Game: a deck, 7 tableaus and 4 foundations"
  @opaque game :: {Stock.t(), [Tableau.t()], [Foundation.t()]}
  @type t :: game

  @typedoc "A move can be from a tableau or from the deck"
  @type from_location :: :tableau | :deck
  @typedoc "A move can from a tableau or the deck"
  @type to_location :: :tableau | :foundation
  @typedoc "Describes moving cards from one location to the other"
  @type move :: {from_location, non_neg_integer, to_location, non_neg_integer, Cards.t()}

  @spec new(Deck.t()) :: Game.t()
  @doc "Create a new empty Game"
  def new(deck) do
    tableaus = create_tableaus(deck)
    foundations = create_foundations()
    deck = Enum.drop(deck, 1 + 2 + 3 + 4 + 5 + 6 + 7)
    {Stock.turn(Stock.new(deck)), tableaus, foundations}
  end

  @spec cards(Game.t()) :: [Cards.t()]
  @doc "Returns the remaining cards in the game"
  def cards({stock, _tableaus, _foundations} = _game) do
    Stock.cards(stock)
  end

  @spec exhausted?(Game.t()) :: boolean
  @doc "Returns whether stock is exhausted"
  def exhausted?({stock, _tableaus, _foundations} = _game) do
    Stock.exhausted?(stock)
  end

  @spec turn(Game.t()) :: Game.t()
  @doc "Turns over one card from down to up pile"
  def turn({stock, tableaus, foundations} = _game) do
    {Stock.turn(stock), tableaus, foundations}
  end

  @spec tableaus(Game.t()) :: [Tableau.t()]
  @doc "Returns the list of 7 tableaus in the game"
  def tableaus({_stock, tableaus, _foundations} = _game) do
    tableaus
  end

  @spec foundations(Game.t()) :: [Foundation.t()]
  @doc "Returns the list of 4 foundations in the game"
  def foundations({_stock, _tableaus, foundations} = _game) do
    foundations
  end

  defp create_tableaus(deck) do
    tableaus =
      for _tableau <- 1..7 do
        Tableau.new()
      end

    distribute_cards(tableaus, deck, 1)
  end

  defp distribute_cards([], _deck, _number) do
    []
  end

  defp distribute_cards([hd | tl], deck, number) do
    [
      Tableau.add(hd, Enum.take(deck, number))
      | distribute_cards(tl, Enum.drop(deck, number), number + 1)
    ]
  end

  defp create_foundations do
    for _foundation <- 1..4 do
      Foundation.new()
    end
  end

  @spec score(Game.t()) :: non_neg_integer
  @doc "Calculate score of game == number of cards moved onto foundations"
  def score({_stock, _tableaus, foundations} = _game) do
    Enum.reduce(foundations, 0, fn foundation, score -> score + length(foundation) end)
  end

  @spec possible_moves(Game.t()) :: [Game.move()]
  @doc "Returns a list of possible moves in the game as { from , from_index , to , to_index}"
  def possible_moves({stock, tableaus, foundations} = _game) do
    solutions =
      find_moves_from_tableaus_to_foundations(tableaus, foundations) ++
        find_moves_from_deck_to_foundations(Stock.top_card(stock), foundations) ++
        find_moves_between_tableaus(tableaus) ++
        find_moves_from_deck_to_tableaus(Stock.top_card(stock), tableaus)

    Enum.filter(solutions, &(&1 != nil))
  end

  defp find_moves_from_tableaus_to_foundations(tableaus, foundations) do
    tableau_cards = bottom_cards_of_tableaus(tableaus)
    move_cards_to_foundation(tableau_cards, foundations)
  end

  defp bottom_cards_of_tableaus(tableaus) do
    cards =
      for tableau <- 0..6 do
        {tableau, Tableau.bottom_card(Enum.at(tableaus, tableau))}
      end

    Enum.filter(cards, fn {_index, card} -> card != nil end)
  end

  defp move_cards_to_foundation(cards, foundations) do
    for {index, card} <- cards do
      foundation =
        Enum.find_index(foundations, fn foundation -> Foundation.can_drop?(foundation, card) end)

      if foundation == nil, do: nil, else: {:tableau, index, :foundation, foundation, card}
    end
  end

  defp find_moves_between_tableaus(tableaus) do
    tableau_cards = top_cards_of_tableaus(tableaus)
    move_cards_to_tableau(tableau_cards, tableaus)
  end

  defp top_cards_of_tableaus(tableaus) do
    cards =
      for tableau <- 6..0 do
        {tableau, Tableau.top_card(Enum.at(tableaus, tableau))}
      end

    Enum.filter(cards, fn {_index, card} -> card != nil end)
  end

  defp move_cards_to_tableau(cards, tableaus) do
    for {index, card} <- cards, tableau_index <- 0..6 do
      from_tableau = Enum.at(tableaus, index)
      from_height = Tableau.cards_down(from_tableau)
      tableau = Enum.at(tableaus, tableau_index)
      to_height = Tableau.cards_up(tableau)

      if Tableau.can_drop?(tableau, card) && (to_height > 0 || from_height > 0),
        do: {:tableau, index, :tableau, tableau_index, card}
    end
  end

  defp find_moves_from_deck_to_foundations(nil, _foundations), do: []

  defp find_moves_from_deck_to_foundations(card, foundations) do
    foundation =
      Enum.find_index(foundations, fn foundation -> Foundation.can_drop?(foundation, card) end)

    if foundation == nil, do: [], else: [{:deck, 0, :foundation, foundation, card}]
  end

  defp find_moves_from_deck_to_tableaus(nil, _tableaus), do: []

  defp find_moves_from_deck_to_tableaus(card, tableaus) do
    for tableau_index <- 0..6 do
      tableau = Enum.at(tableaus, tableau_index)

      if Tableau.can_drop?(tableau, card),
        do: {:deck, 0, :tableau, tableau_index, card}
    end
  end

  @spec perform(Game.t(), Game.move()) :: Game.t()
  @doc "Perform the given move on the game"
  def perform(
        {stock, tableaus, foundations} = _game,
        {:tableau, tableau_index, :foundation, foundation_index, _card_to_move}
      ) do
    tableau = Enum.at(tableaus, tableau_index)
    card = Tableau.bottom_card(tableau)
    tableaus = List.replace_at(tableaus, tableau_index, Tableau.take(tableau))
    foundation = Enum.at(foundations, foundation_index)

    foundations =
      List.replace_at(foundations, foundation_index, Foundation.drop(foundation, card))

    {stock, tableaus, foundations}
  end

  def perform(
        {stock, tableaus, foundations} = _game,
        {:tableau, from_tableau_index, :tableau, to_tableau_index, _card_to_move}
      ) do
    tableau = Enum.at(tableaus, from_tableau_index)
    cards = Tableau.up(tableau)
    tableaus = List.replace_at(tableaus, from_tableau_index, Tableau.take_all(tableau))

    tableau = Enum.at(tableaus, to_tableau_index)
    tableau = Tableau.drop_cards(tableau, cards)
    tableaus = List.replace_at(tableaus, to_tableau_index, tableau)

    {stock, tableaus, foundations}
  end

  def perform(
        {stock, tableaus, foundations} = _game,
        {:deck, _, :foundation, foundation_index, _card_to_move}
      ) do
    card = Stock.top_card(stock)
    stock = Stock.take(stock)
    foundation = Enum.at(foundations, foundation_index)

    foundations =
      List.replace_at(foundations, foundation_index, Foundation.drop(foundation, card))

    {stock, tableaus, foundations}
  end

  def perform(
        {stock, tableaus, foundations} = _game,
        {:deck, _, :tableau, to_tableau_index, _card_to_move}
      ) do
    card = Stock.top_card(stock)
    stock = Stock.take(stock)

    tableau = Enum.at(tableaus, to_tableau_index)
    tableaus = List.replace_at(tableaus, to_tableau_index, Tableau.drop(tableau, card))

    {stock, tableaus, foundations}
  end

  def reshuffle({{[], _waste} = stock, tableaus, foundations} = _game) do
    {Stock.retry(stock), tableaus, foundations}
  end

  def reshuffle(game), do: game
end
