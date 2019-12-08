defmodule Intcode do
  @code_to_instruction_size %{1 => 4, 2 => 4, 3 => 2, 4 => 2, 5 => 3, 6 => 3, 7 => 4, 8 => 4, 99 => 1}
  @input 1
  @input2 5


  def get_input() do
    File.read!("./input.txt")
    |> String.split(",")
    |> Enum.reduce({0, %{}}, fn (s, {i, code}) -> {i + 1, Map.put(code, i, s |> String.to_integer)} end)
    |> elem(1)
  end

  def run do
    code =
      get_input()

    execute(code)
  end

  def execute(code), do: fetch(code, next_input(code, 0), 0)

  defp instruction_without_mode(instruction) do
    instruction
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.slice(-2..-1)
    |> String.to_integer()
  end

  defp get_modes(instruction) do
    instruction
    |> Integer.to_string()
    |> String.pad_leading(5, "0")
    |> String.slice(0..-3)
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp get_param(code, pos, 0), do: Map.get(code, pos)
  defp get_param(_code, val, 1), do: val

  def execute(code, {1, a, b, pos}, i) do
    code = Map.put(code, pos, a + b)
    new_i = i + Map.get(@code_to_instruction_size, 1)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, {2, a, b, pos}, i) do
    code = Map.put(code, pos, a * b)
    new_i = i + Map.get(@code_to_instruction_size, 2)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, {3, pos}, i) do
    code = Map.put(code, pos, @input2)
    new_i = i + Map.get(@code_to_instruction_size, 3)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, {4, output_pos}, i) do
    IO.puts("Output: #{Map.get(code, output_pos)}")
    new_i = i + Map.get(@code_to_instruction_size, 3)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, {5, a, b}, i) do
    if a != 0 do
      fetch(code, next_input(code, b), b)
    else
      new_i = i + Map.get(@code_to_instruction_size, 5)
      fetch(code, next_input(code, new_i), new_i)
    end
  end

  def execute(code, {6, a, b}, i) do
    if a == 0 do
      fetch(code, next_input(code, b), b)
    else
      new_i = i + Map.get(@code_to_instruction_size, 6)
      fetch(code, next_input(code, new_i), new_i)
    end
  end

  def execute(code, {7, a, b, pos}, i) do
    new_value = if a < b, do: 1, else: 0

    code = Map.put(code, pos, new_value)
    new_i = i + Map.get(@code_to_instruction_size, 7)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, {8, a, b, pos}, i) do
    new_value = if a == b, do: 1, else: 0

    code = Map.put(code, pos, new_value)
    new_i = i + Map.get(@code_to_instruction_size, 7)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, 99, _) do
    # done
  end

  def fetch(code, {instruction, a, b, pos}, i) do
    modes = get_modes(instruction)

    execute(
      code, {
        instruction_without_mode(instruction),
        get_param(code, a, Enum.at(modes, 2)),
        get_param(code, b, Enum.at(modes, 1)),
        pos
      },
      i
    )
  end

  # for opcodes 3, 4
  def fetch(code, {instruction, pos}, i) do
    modes = get_modes(instruction)

    execute(
      code, {
        instruction_without_mode(instruction),
        pos
      },
      i
    )
  end

  # for opcodes 5, 6
  def fetch(code, {instruction, a, b}, i) do
    modes = get_modes(instruction)

    execute(
      code, {
        instruction_without_mode(instruction),
        get_param(code, a, Enum.at(modes, 2)),
        get_param(code, b, Enum.at(modes, 1))
      },
      i
    )
  end

  def fetch(code, {99}, i), do: execute(code, 99, i)


  defp next_input(code, new_i) do
    new_opcode = Map.get(code, new_i) |> instruction_without_mode()

    (new_i)..(new_i + Map.get(@code_to_instruction_size, new_opcode) - 1)
    |> Enum.map(fn i -> Map.get(code, i) end)
    |> List.to_tuple()
    |> IO.inspect()
  end
end
