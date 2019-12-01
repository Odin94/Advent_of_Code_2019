defmodule MassCalculator do
  def get_rocket_weights() do
    File.stream!("./input.txt", [], :line)
    |> Enum.map(fn s -> s |> String.trim() |> String.to_integer() end)
  end

  def get_required_fuel() do
    get_rocket_weights()
    |> weight_to_required_fuel()
    |> print_weight_sum()
    |> fuel_weight_to_required_additional_fuel()
    |> Enum.sum()
  end

  defp weight_to_required_fuel(weight) do
    weight
    |> Enum.map(&weight_to_fuel/1)
  end

  defp fuel_weight_to_required_additional_fuel(fuel_weights) do
    fuel_weights
    |> Enum.map(fn fuel -> fuel |> add_fuel_to_fuel(fuel) end)
  end

  def add_fuel_to_fuel(fuel, total_fuel) do
    added_fuel = weight_to_fuel(fuel)
    if added_fuel > 0 do
      add_fuel_to_fuel(added_fuel, total_fuel + added_fuel)
    else
      total_fuel
    end
  end

  defp weight_to_fuel(weight), do: weight |> div(3) |> sub(2)

  defp sub(a, b), do: a - b

  defp print_weight_sum(weights) do
    weights
    |> Enum.sum()
    |> IO.inspect()

    weights
  end
end
