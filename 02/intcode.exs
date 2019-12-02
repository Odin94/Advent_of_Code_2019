defmodule Intcode do
  def get_input() do
    File.read!("./input.txt")
    |> String.split(",")
    |> Enum.reduce({0, %{}}, fn (s, {i, code}) -> {i + 1, Map.put(code, i, s |> String.to_integer)} end)
    |> elem(1)
  end

  def run do
    code =
      get_input()
      |> update_code(12, 2)

    execute(code)
  end

  def execute(code), do: execute(code, next_four(code, 0), 0)

  def execute(code, {1, a, b, pos}, i) do
    new_code = Map.put(code, pos, Map.get(code, a) + Map.get(code, b))
    new_i = i + 4

    execute(new_code, next_four(code, new_i), new_i)
  end


  def execute(code, {2, a, b, pos}, i) do
    new_code = Map.put(code, pos, Map.get(code, a) * Map.get(code, b))
    new_i = i + 4

    execute(new_code, next_four(code, new_i), new_i)
  end

  def execute(code, 99, _) do
    Map.get(code, 0)
  end

  defp next_four(code, i) do
    case Map.get(code, i) do
      99 -> 99
      _ -> {Map.get(code, i), Map.get(code, i + 1), Map.get(code, i + 2), Map.get(code, i + 3)}
    end
  end

  defp update_code(code, noun, verb) do
    code
    |> Map.put(1, noun)
    |> Map.put(2, verb)
  end


  # Part 2

  def run2() do
    get_input()
    |> find_input_to_produce_value(19690720)
  end

  def find_input_to_produce_value(code, target_value) do
    for noun <- 1..99 do
      for verb <- 1..99 do
        execute2(code, noun, verb)
      end
    end
    |> List.flatten()
    |> Enum.filter(fn {value, _noun, _verb} -> value == target_value end)
    |> Enum.map(fn {_value, noun, verb} -> "noun: #{noun}, verb: #{verb}, solution: #{100 * noun + verb}" end)
  end

  defp execute2(code, noun, verb) do
    value =
      code
      |> update_code(noun, verb)
      |> execute()

    {value, noun, verb}
  end
end
