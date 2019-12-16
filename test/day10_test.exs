defmodule Day10Test do
  use ExUnit.Case

  alias Day10.Belt

  @input_test1 """
  .#..#
  .....
  #####
  ....#
  ...##
  """
  test "part1 test 1" do
    assert Belt.new(@input_test1)
           |> Belt.best_monitoring_station() == {8, {3, 4}}
  end

  @input_test2 """
  ......#.#.
  #..#.#....
  ..#######.
  .#.#.###..
  .#..#.....
  ..#....#.#
  #..#....#.
  .##.#..###
  ##...#..#.
  .#....####
  """
  test "part1 test 2" do
    assert Belt.new(@input_test2)
           |> Belt.best_monitoring_station() == {33, {5, 8}}
  end

  @input_test3 """
  #.#...#.#.
  .###....#.
  .#....#...
  ##.#.#.#.#
  ....#.#.#.
  .##..###.#
  ..#...##..
  ..##....##
  ......#...
  .####.###.
  """
  test "part1 test 3" do
    assert Belt.new(@input_test3)
           |> Belt.best_monitoring_station() == {35, {1, 2}}
  end

  @input_test4 """
  .#..#..###
  ####.###.#
  ....###.#.
  ..###.##.#
  ##.##.#.#.
  ....###..#
  ..#.#..#.#
  #..#.#.###
  .##...##.#
  .....#.#..
  """
  test "part1 test 4" do
    assert Belt.new(@input_test4)
           |> Belt.best_monitoring_station() == {41, {6, 3}}
  end

  @input_test5 """
  .#..##.###...#######
  ##.############..##.
  .#.######.########.#
  .###.#######.####.#.
  #####.##.#.##.###.##
  ..#####..#.#########
  ####################
  #.####....###.#.#.##
  ##.#################
  #####.##.###..####..
  ..######..##.#######
  ####.##.####...##..#
  .#####..#.######.###
  ##...#.##########...
  #.##########.#######
  .####.#.###.###.#.##
  ....##.##.###..#####
  .#.#.###########.###
  #.#.#.#####.####.###
  ###.##.####.##.#..##
  """
  test "part1 test 5" do
    assert Belt.new(@input_test5)
           |> Belt.best_monitoring_station() == {210, {11, 13}}
  end

  @input_test6 """
  .#....#####...#..
  ##...##.#####..##
  ##...#...#.#####.
  ..#.....#...###..
  ..#.#.....#....##
  """
  test "part2 test 6" do
    belt = Belt.new(@input_test6)
    {_, {x, y}} = Belt.best_monitoring_station(belt)
    assert Belt.kill_at(belt, {x, y}, 36) == {36, {14, 3}}
  end
end
