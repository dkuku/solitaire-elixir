# Separate test modules for each test so that they're run in parallel

defmodule PerformanceTest1 do
  @moduledoc false
  use ExUnit.Case, async: true

  @tag :performance
  test "Run a complete game to check no scoring regressions 1..2000" do
    score = Player.play_games(1..2000)

    assert score == 17_940
  end
end

defmodule PerformanceTest2 do
  @moduledoc false
  use ExUnit.Case, async: true

  @tag :performance
  test "Run a complete game to check no scoring regressions 2001..4000" do
    score = Player.play_games(2001..4000)

    assert score == 18_139
  end
end

defmodule PerformanceTest3 do
  @moduledoc false
  use ExUnit.Case, async: true

  @tag :performance
  test "Run a complete game to check no scoring regressions 4001..6000" do
    score = Player.play_games(4001..6000)

    assert score == 19_036
  end
end

defmodule PerformanceTest4 do
  @moduledoc false
  use ExUnit.Case, async: true

  @tag :performance
  test "Run a complete game to check no scoring regressions 6001..8000" do
    score = Player.play_games(6001..8000)

    assert score == 19_126
  end
end

defmodule PerformanceTest5 do
  @moduledoc false
  use ExUnit.Case, async: true

  @tag :performance
  test "Run a complete game to check no scoring regressions 8001..10000" do
    score = Player.play_games(8001..10_000)

    assert score == 18_766
  end
end

defmodule PerformanceTest6 do
  @moduledoc false
  use ExUnit.Case, async: true

  @tag :performance
  test "Run a complete game to check no scoring regressions 10001..12000" do
    score = Player.play_games(10_001..12_000)

    assert score == 18_710
  end
end
