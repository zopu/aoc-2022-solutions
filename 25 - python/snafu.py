import math

def snafu_to_decimal(snafu_str):
    chars = [c for c in snafu_str if c != "\n"]
    chars.reverse()
    column_val = 1
    decimal = 0
    for c in chars:
        num = 0
        match c:
            case '=':
                num = -2
            case '-':
                num = -1
            case _:
                num = int(c)
        decimal += (num * column_val)
        column_val *= 5
    return decimal

def decimal_to_snafu(d):
    num_left = d
    chars = []
    carry = 0
    while num_left > 0 or carry > 0:
        num = (num_left % 5)
        match (num + carry):
            case n if n < 3:
                c = str(n)
                carry = 0
            case 3:
                c = '='
                carry = 1
            case 4:
                c = '-'
                carry = 1
            case 5:
                c = '0'
                carry = 1
        chars.append(c)
        num_left = math.floor((num_left - num) / 5)
    chars.reverse()
    return ''.join(chars)

def part1(lines):
    result = decimal_to_snafu(sum(map(snafu_to_decimal,lines)))
    print(f"Part 1: {result}")

if __name__ == "__main__":
    tests = [[1, "1"], [2, "2"], [3, "1="], [4, "1-"], [5, "10"],[2022, "1=11-2"], [12345, "1-0---0"], [314159265, "1121-1110-1=0"]]
    for [d, s] in tests:
        result = snafu_to_decimal(s)
        assert result == d, f"Bad conversion for {s} : Expected {d} but got {result}"
        result = decimal_to_snafu(d)
        assert result == s, f"Bad conversion for {d} : Expected {s} but got {result}"
    part1(open("input.txt"))