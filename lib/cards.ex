defmodule Solitaire.Cards do
  @moduledoc """
  A card has a suit and a value

  ## Examples

      iex> length(Solitaire.Cards.suits)
      4
      iex> length(Solitaire.Cards.values)
      13

  """

  @type suit :: :hearts | :diams | :spades | :clubs
  @type value :: non_neg_integer
  @type colour :: :red | :black
  @type card :: {suit, value}
  @type t :: card

  @spec new(suit, value) :: card
  @doc "Make a  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end card with given suit and value"
  def new(suit, value) do
    {suit, value}
  end

  @spec suit_of(card) :: suit
  @doc "Returns suit part of card"
  def suit_of({suit, _value}) do
    suit
  end

  @spec value_of(card) :: value
  @doc "Returns value part of card"
  def value_of({_suit, value}) do
    value
  end

  @spec colour_of(card) :: colour
  @doc "Return the colour of the card"
  def colour_of({suit, _value}) do
    colour_of_suit(suit)
  end

  defp colour_of_suit(:hearts), do: :red
  defp colour_of_suit(:diams), do: :red
  defp colour_of_suit(:clubs), do: :black
  defp colour_of_suit(:spades), do: :black

  @spec suits :: [suit]
  @doc "List of possible card suits"
  def suits do
    [:hearts, :diams, :spades, :clubs]
  end

  @spec values :: [value]
  @doc "List of possible card values"
  def values do
    Enum.to_list(1..13)
  end
end
