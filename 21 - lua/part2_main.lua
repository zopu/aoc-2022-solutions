require "build.part2"

humn_result = 0;

function humn()
    return humn_result;
end

-- Do a search of humn_result values to find the right result
function search(low, high)
    print(string.format("Searching (%f,%f)", low, high));
    humn_result = low;
    r_low = root();
    humn_result = high;
    r_high = root();
    print(string.format("--results (%f,%f)", r_low, r_high));


    -- If either result is 0:
    if r_low == 0.0 or r_high == 0.0 then
        print("Success!");
        return true
    end

    -- If both results are < 0 or > 0, expand both:
    if (r_low < 0.0 and r_high < 0.0) or (r_low > 0.0 and r_high > 0.0) then
        print("Expanding");
        diff = math.abs(low - high)
        return search(low - diff, high + diff)
    end

    -- results are either side of 0. Check mid point.
    mid = math.floor((low + high) / 2)
    humn_result = mid
    r_mid = root();
    if r_low < 0.0 and r_mid > 0.0 then
        return search(low, mid)
    end
    if r_low > 0.0 and r_mid < 0.0 then
        return search(low, mid)
    end

    return search(mid, high)
end

search(0, 10000);