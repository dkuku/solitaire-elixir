defmodule Solitaire.Game do
  @moduledoc """
  A Solitaire Game

  ## Examples

      iex> deck = Solitaire.Deck.shuffle(Solitaire.Deck.new,1234)
      iex> game = Solitaire.Game.new(deck)
      iex> length(Solitaire.Game.tableaus(game))
      7



  """

  alias Solitaire.Game, as: Game
  alias Solitaire.Foundation, as: Foundation
  alias Solitaire.Tableau, as: Tableau
  alias Solitaire.Deck, as: Deck
  alias Solitaire.Cards, as: Cards


  @opaque game :: { [ Cards.t ] , [ Tableau.t] , [ Foundation.t ] }
  @type t :: game

  @type from_location :: :tableau | :foundation | :deck
  @type to_location :: :tableau | :foundation 
  @type move :: {from_location , non_neg_integer , to_location , non_neg_integer}

  @spec new(Deck.t) :: Game.t
  @doc "Create a new empty Game"
  def new(deck) do
    tableaus = create_tableaus(deck)
    foundations = create_foundations()
    deck = Enum.drop(deck,1+2+3+4+5+6+7)
    { deck , tableaus , foundations }
  end
  
  @spec cards(Game.t) :: [ Cards.t]
  @doc "Returns the remaining cards in the game"
  def cards({cards,_tableaus,_foundations}=_game) do
    cards
  end

  @spec tableaus(Game.t) :: [ Tableau.t]
  @doc "Returns the list of 7 tableaus in the game"
  def tableaus({_cards,tableaus,_foundations}=_game) do
    tableaus
  end

  @spec foundations(Game.t) :: [ Foundation.t]
  @doc "Returns the list of 4 foundations in the game"
  def foundations({_cards,_tableaus,foundations}=_game) do
    foundations
  end

  defp create_tableaus(deck) do
    tableaus = for _tableau <- 1..7 do
      Tableau.new
    end

    distribute_cards(tableaus,deck,1)
  end

  defp distribute_cards([],_deck,_number) do
    []
  end

  defp distribute_cards([hd|tl],deck,number) do
    [ Tableau.add(hd,Enum.take(deck,number)) | distribute_cards(tl,Enum.drop(deck,number),number+1) ]
  end

  defp create_foundations() do
    for _foundation <- 1..4 do
      Foundation.new
    end
  end

  @spec pretty_print(Game.t) :: :ok
  @doc "Prints a readable version of the game"
  def pretty_print({cards,tableaus,foundations}) do
    IO.puts ""
    IO.inspect cards
    IO.puts "Tableaus"
    Enum.each(tableaus,fn(tableau) -> IO.inspect(tableau) end)
    IO.puts "Foundations"
    Enum.each(foundations,fn(foundation) -> IO.inspect(foundation) end)
  end

  @spec score(Game.t) :: non_neg_integer
  @doc "Calculate score of game == number of cards moved onto foundations"
  def score({_cards,_tableaus,foundations}) do
    Enum.reduce(foundations,0,fn(foundation,score) -> score + length(foundation) end)
  end

  @spec possible_moves(Game.t) :: [ Game.move ] 
  @doc "Returns a list of possible moves in the game as { from , from_index , to , to_index}"
  def possible_moves({_cards,tableaus,foundations}) do
    solutions = find_moves_from_tableaus_to_foundations(tableaus,foundations)
    Enum.filter(solutions,&(&1 != nil))
  end

  defp find_moves_from_tableaus_to_foundations(tableaus,foundations) do
    tableau_cards = bottom_cards_of_tableaus(tableaus)
    move_cards_to_foundation(tableau_cards,foundations)
  end

  defp bottom_cards_of_tableaus(tableaus) do
    cards = for tableau <- 0..6 do
      { tableau , Tableau.bottom_card(Enum.at(tableaus,tableau)) }
    end
    Enum.filter(cards,fn({_index,card}) -> card != nil end)
  end

  defp move_cards_to_foundation(cards,foundations) do
    for {index,card} <- cards do
      foundation = Enum.find_index(foundations,fn(foundation) -> Foundation.can_drop?(foundation,card) end)
      if foundation != nil, do: { :tableau , index , :foundation , foundation }, else: nil
    end
  end

  @spec perform(Game.t,Game.move) :: Game.t
  @doc "Perform the given move on the game"
  def perform({deck,tableaus,foundations},{:tableau , tableau_index, :foundation, foundation_index}) do
    tableau = Enum.at(tableaus,tableau_index)
    card = Tableau.bottom_card(tableau)
    tableaus = List.replace_at(tableaus,tableau_index,Tableau.take(tableau))
    foundation = Enum.at(foundations,foundation_index)
    foundations = List.replace_at(foundations,foundation_index,Foundation.drop(foundation,card))
    {deck,tableaus,foundations}
  end

end
