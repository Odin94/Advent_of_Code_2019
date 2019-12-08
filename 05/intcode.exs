defmodule Intcode do
  @code_to_instruction_size %{1 => 4, 2 => 4, 3 => 2, 4 => 2, 99 => 1}
  @input 1

  ##### TODO: Misunderstood how modes work, actually has up to 3 mode flags (remember, no leading 0s)
  ##### Also see if you can use rem() to access opcodes or int > str > padleft > graphemes > Enu.at()

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

  def execute(code), do: execute(code, next_input(code, 0), 0)

  defp instruction_without_mode(code) when code > 100 do
    code
      |> Integer.to_string()
      |> String.slice(-2..-1)
      |> String.to_integer()
  end
  defp instruction_without_mode(code), do: code

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
    code = Map.put(code, pos, @input)
    new_i = i + Map.get(@code_to_instruction_size, 3)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, {4, output}, i) do
    new_i = i + Map.get(@code_to_instruction_size, 3)

    fetch(code, next_input(code, new_i), new_i)
  end

  def execute(code, 99, _) do
    Map.get(code, 0)
  end

  def fetch(code, {instruction, a, b, pos}, i) when instruction > 1000 do
    case instruction |> Integer.to_string() do
      "11" <> _ -> execute(code, {instruction_without_mode(instruction), a, b, pos}, i)
      "10" <> _ -> execute(code, {instruction_without_mode(instruction), Map.get(code, a), b, pos}, i)
    end
  end

  def fetch(code, {instruction, a, b, pos}, i) when instruction > 100 do
    execute(code, {instruction_without_mode(instruction), a, Map.get(code, b), pos}, i)
  end

  # for opcodes 3, 4
  def fetch(code, {instruction, pos, a}, i) when instruction > 100 do
    execute(code, {instruction_without_mode(instruction), Map.get(code, pos)}, i)
  end

  def fetch(code, {instruction, a, b, pos}, i), do: execute(code, {instruction, Map.get(code, a), Map.get(code, b), pos}, i)

  defp next_input(code, new_i) do
    new_opcode = Map.get(code, new_i) |> instruction_without_mode()
    IO.puts(new_opcode)

    (new_i)..(new_i + Map.get(@code_to_instruction_size, new_opcode) - 1)
    |> Enum.map(fn i -> Map.get(code, i) end)
    |> List.to_tuple()
    |> IO.inspect()
  end
end
