defmodule D20 do
  @moduledoc """
  Advent of code 2022 Day 20
  """
  def make_index_list_and_map(list) do
    im = list |> Enum.with_index() |> Enum.reduce(%{}, fn {e, i}, acc -> Map.put(acc, i, e) end)
    il = Enum.to_list(0..(length(list) - 1))
    {il, im}
  end

  def make_list(index_list, index_map) do
    Enum.map(index_list, fn e -> index_map[e] end)
  end

  def shift_with_im(list, index_map, num) do
    {before, [^num | rest]} = Enum.split_while(list, fn e -> e != num end)
    popped = before ++ rest
    shift_num = index_map[num]

    new_pos = rem(shift_num + length(before), length(popped))
    cond do
      shift_num == 0 -> list
      new_pos < 0 -> List.insert_at(popped, new_pos - 1, num)
      true -> List.insert_at(popped, new_pos, num)
    end
  end

  def shift_all(list) do
    {il, im} = make_index_list_and_map(list)

    shifted =
      Enum.reduce(il, il, fn e, acc ->
        shift_with_im(acc, im, e)
      end)

    make_list(shifted, im)
  end

  def nth_after_zero(list, n) do
    zero_pos = Enum.find_index(list, fn e -> e == 0 end)
    Enum.at(list, rem(zero_pos + n, length(list)))
  end

  def part1(list_of_nums) do
    shifted = shift_all(list_of_nums)
    Enum.sum([
      nth_after_zero(shifted, 1000),
      nth_after_zero(shifted, 2000),
      nth_after_zero(shifted, 3000)
    ])
  end

  def part2_one_shift(il, current, im) do
    Enum.reduce(il, current, fn e, acc ->
      shift_with_im(acc, im, e)
    end)
  end

  def part2(list_of_nums) do
    dc = 811589153
    decrypted = Enum.map(list_of_nums, fn n -> n * dc end)
    {il, im} = make_index_list_and_map(decrypted)

    all_shifted = Enum.reduce(0..9, il, fn _i, current ->
      part2_one_shift(il, current, im)
    end)
    final = make_list(all_shifted, im)
    Enum.sum([
      nth_after_zero(final, 1000),
      nth_after_zero(final, 2000),
      nth_after_zero(final, 3000)
    ])
  end
end
