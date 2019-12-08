defmodule Password do
  @min 183564
  @max 657474


  def run do
    generate_valid_passwords(@min, @max)
  end

  defp generate_valid_passwords(min, max) do
    {min, max}
    |> to_six_digit_codes()
    |> with_adjacent_same_digits()
    |> without_decreasing_digits()
    |> Enum.count()
  end

  defp to_six_digit_codes({min, max}) do
    0..(max - min)
    |> Enum.map(fn i -> i + @min end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(fn s -> s |> String.split("", trim: true) |> Enum.map(&String.to_integer/1) end)
  end

  defp with_adjacent_same_digits(codes) do
    codes
    |> Enum.filter(&has_adjacent_digits/1)
  end

  defp has_adjacent_digits([]), do: false
  defp has_adjacent_digits([_]), do: false
  defp has_adjacent_digits([a, a | _]), do: true
  defp has_adjacent_digits([a, b | tail]), do: has_adjacent_digits([b | tail])

  defp without_decreasing_digits(codes) do
    codes
    |> Enum.filter(&has_no_decreasing_digits/1)
  end

  defp has_no_decreasing_digits([]), do: true
  defp has_no_decreasing_digits([_]), do: true
  defp has_no_decreasing_digits([a, b | _]) when a > b, do: false
  defp has_no_decreasing_digits([_head | tail]), do: has_no_decreasing_digits(tail)
end
