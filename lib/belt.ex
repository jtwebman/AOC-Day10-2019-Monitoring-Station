defmodule Day10.Belt do
  alias Day10.Gcd
  defstruct [:asteroids, :max_x, :max_y]

  def new(belt_text) do
    belt = %__MODULE__{asteroids: %{}}

    {y, new_belt} =
      belt_text
      |> String.split("\n", trim: true)
      |> Enum.reduce({0, belt}, &parse_line/2)

    Map.put(new_belt, :max_y, y)
  end

  defp parse_line(line, {y, %__MODULE__{} = belt}) do
    {x, _, new_belt} =
      line
      |> String.split("", trim: true)
      |> Enum.reduce({0, y, belt}, &parse_cell/2)

    {y + 1, Map.put(new_belt, :max_x, x)}
  end

  defp parse_cell(
         cell,
         {x, y, %__MODULE__{asteroids: asteroids} = belt}
       ) do
    case cell do
      "#" -> {x + 1, y, Map.put(belt, :asteroids, Map.put(asteroids, {x, y}, :unknown))}
      _ -> {x + 1, y, belt}
    end
  end

  def kill_at(belt, station, at) do
    kill(belt, station)
    |> Enum.find(fn {count, _} -> count == at end)
  end

  def kill(%__MODULE__{asteroids: asteroids}, station) do
    {targets, _} = Enum.reduce(asteroids, {%{}, station}, &build_attack/2)

    keys =
      targets
      |> Map.keys()
      |> Enum.sort()

    {_, attacked} =
      attack(targets, keys, station, [])
      |> Enum.reduce({1, []}, fn target, {count, ordered_attacks} ->
        {count + 1, ordered_attacks ++ [{count, target}]}
      end)

    attacked
  end

  defp attack(targets, [], _, attacked) when map_size(targets) == 0 do
    attacked
  end

  defp attack(targets, [], station, attacked) do
    keys =
      targets
      |> Map.keys()
      |> Enum.sort()

    attack(targets, keys, station, attacked)
  end

  defp attack(targets, [target | rest], {station_x, station_y} = station, attacked) do
    {[{x, y} | _], targets} =
      Map.get_and_update(targets, target, fn [_ | remaining] = current_value ->
        case remaining do
          [] -> :pop
          _ -> {current_value, remaining}
        end
      end)

    attack(targets, rest, station, attacked ++ [{station_x + x, station_y + y}])
  end

  defp build_attack({{x, y}, _}, {attack_map, {station_x, station_y} = station})
       when x == station_x and y == station_y do
    {attack_map, station}
  end

  defp build_attack({{x, y}, _}, {attack_map, {station_x, station_y} = station}) do
    ratio_x = x - station_x
    ratio_y = y - station_y

    angle =
      case :math.atan2(ratio_y, ratio_x) * 180 / :math.pi() + 90 do
        a when a < 0 -> 90 - abs(a) + 270
        a -> a
      end

    {_, new_attack_map} =
      Map.get_and_update(attack_map, angle, fn current_value ->
        case current_value do
          nil -> {current_value, [{ratio_x, ratio_y}]}
          _ -> {current_value, Enum.sort_by([{ratio_x, ratio_y}] ++ current_value, &dist/1)}
        end
      end)

    {new_attack_map, station}
  end

  defp dist({x, y}) do
    abs(x) + abs(y)
  end

  def best_monitoring_station(%__MODULE__{asteroids: asteroids} = belt) do
    asteroids
    |> Enum.reduce({0, nil}, fn {{x, y}, _}, {current, _} = stats ->
      in_view = find_in_view(belt, {x, y})

      case current < in_view do
        true -> {in_view, {x, y}}
        _ -> stats
      end
    end)
  end

  defp find_in_view(
         %__MODULE__{
           asteroids: asteroids
         },
         station
       ) do
    {new_asteroids, _} = Enum.reduce(asteroids, {asteroids, station}, &find_asteroid_status/2)
    Enum.count(new_asteroids, fn {_, val} -> val == :in_view end)
  end

  defp find_asteroid_status(
         {{x, y}, _},
         {asteroids, {station_x, station_y} = station}
       )
       when x == station_x and y == station_y do
    {Map.put(asteroids, {x, y}, :station), station}
  end

  defp find_asteroid_status(
         {{x, y}, current_value},
         {asteroids, {station_x, station_y} = station}
       ) do
    case current_value do
      :station ->
        {asteroids, station}

      _ ->
        ratio_x = station_x - x
        ratio_y = station_y - y
        gcd = abs(Gcd.gcd(ratio_x, ratio_y))
        step_x = trunc(ratio_x / gcd)
        step_y = trunc(ratio_y / gcd)

        {Map.put(
           asteroids,
           {x, y},
           asteroid_status({x + step_x, y + step_y}, {step_x, step_y}, asteroids, station)
         ), station}
    end
  end

  defp asteroid_status({x, y}, _, _, {station_x, station_y})
       when x == station_x and y == station_y do
    :in_view
  end

  defp asteroid_status({x, y}, {step_x, step_y} = step, asteroids, station) do
    case Map.has_key?(asteroids, {x, y}) do
      true -> :blocked
      _ -> asteroid_status({x + step_x, y + step_y}, step, asteroids, station)
    end
  end

  def render(%__MODULE__{} = belt) do
    render_lines(0, belt)
  end

  defp render_lines(
         y,
         %__MODULE__{
           max_y: max_y
         } = belt
       )
       when y > max_y do
    belt
  end

  defp render_lines(
         y,
         %__MODULE__{} = belt
       ) do
    render_cell(0, y, belt)
  end

  defp render_cell(
         x,
         y,
         %__MODULE__{
           max_x: max_x
         } = belt
       )
       when x > max_x do
    IO.write("\n")
    render_lines(y + 1, belt)
  end

  defp render_cell(
         x,
         y,
         %__MODULE__{
           asteroids: asteroids
         } = belt
       ) do
    case Map.get(asteroids, {x, y}) do
      :station -> IO.write("O")
      :in_view -> IO.write("*")
      :blocked -> IO.write("X")
      _ -> IO.write(".")
    end

    render_cell(x + 1, y, belt)
  end
end
