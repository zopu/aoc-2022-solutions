defmodule D20Test do
  use ExUnit.Case
  doctest D20

  def get_input(file) do
    {:ok, text} = File.read(file)
    text |> String.split("\n") |> Enum.map(&String.to_integer(&1))
  end

  test "part1_sm" do
    input = get_input("input_sm.txt")
    assert D20.part1(input) == 3
  end

  test "part1" do
    input = get_input("input.txt")
    # Wrong!
    # 8206 is too high
    assert D20.part1(input) == 5962
  end

  test "part2_sm" do
    input = get_input("input_sm.txt")
    assert D20.part2(input) == 1623178306
  end

  test "part2" do
    input = get_input("input.txt")
    assert D20.part2(input) == 9862431387256
  end

  test "index map" do
    l = [5, 10]
    {_il, im} = D20.make_index_list_and_map(l)
    assert im == %{0 => 5, 1 => 10}
    ex_l = [1, 2, -3, 3, -2, 0, 4]
    {_il, im} = D20.make_index_list_and_map(ex_l)
    assert im == %{0 => 1, 1 => 2, 2 => -3, 3 => 3, 4 => -2, 5 => 0, 6 => 4}
  end

  test "shifting with index map" do
    l = [1, 2, 3, 4, 5]
    {il, im} = D20.make_index_list_and_map(l)
    shifted = D20.shift_with_im(il, im, 0)
    assert [1, 0, 2, 3, 4] == shifted
    assert [2, 1, 3, 4, 5] == D20.make_list(shifted, im)
  end

  test "shifting with big negative" do
    l = [1, 2, -7]
    {il, im} = D20.make_index_list_and_map(l)
    shifted = D20.shift_with_im(il, im, 2)
    assert [0, 2, 1] == shifted
  end

  test "shifting with big positive" do
    l = [1, 10, 2]
    {il, im} = D20.make_index_list_and_map(l)
    shifted = D20.shift_with_im(il, im, 1)
    assert [0, 1, 2] == shifted
  end

  test "shifting zero" do
    l = [1, 0, 3]
    {il, im} = D20.make_index_list_and_map(l)
    shifted = D20.shift_with_im(il, im, 1)
    assert [0, 1, 2] == shifted
  end

  test "shift multiple of list length" do
    l = [1, 8, 2]
    {il, im} = D20.make_index_list_and_map(l)
    shifted = D20.shift_with_im(il, im, 1)
    assert [0, 1, 2] == shifted
  end

  # test "shifting example" do
  #   ex_l = [1, 2, -3, 3, -2, 0, 4]
  #   ex_l_1 = D20.shift(ex_l, 1)
  #   assert [2, 1, -3, 3, -2, 0, 4] == ex_l_1
  #   ex_l_2 = D20.shift(ex_l_1, 2)
  #   assert [1, -3, 2, 3, -2, 0, 4] == ex_l_2
  #   ex_l_3 = D20.shift(ex_l_2, -3)
  #   assert [1, 2, 3, -2, -3, 0, 4] == ex_l_3
  #   ex_l_4 = D20.shift(ex_l_3, 3)
  #   assert [1, 2, -2, -3, 0, 3, 4] == ex_l_4
  #   ex_l_5 = D20.shift(ex_l_4, -2)
  #   assert [1, 2, -3, 0, 3, 4, -2] == ex_l_5
  #   ex_l_6 = D20.shift(ex_l_5, 0)
  #   assert [1, 2, -3, 0, 3, 4, -2] == ex_l_6
  #   ex_l_7 = D20.shift(ex_l_5, 4)
  #   assert [1, 2, -3, 4, 0, 3, -2] == ex_l_7
  # end

  test "shifting_all" do
    l = [1, 2, -3, 3, -2, 0, 4]
    # assert [1, 2, -3, 4, 0, 3, -2] == D20.shift_all(l)
    assert [-2, 1, 2, -3, 4, 0, 3] == D20.shift_all(l)
  end

  test "find nth element after 0, wrapping" do
    l = [1, 2, -3, 4, 0, 3, -2]
    assert 4 == D20.nth_after_zero(l, 1000)
  end
end
