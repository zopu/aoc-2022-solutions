using Random;

# Parse the input. Initially into some dictionaries using the names,
# and then convert into vectors using indices to represent locations

line_re = r"Valve ([A-Z][A-Z]) has flow rate=([0-9]+); tunnels? leads? to valves? (.*)"

flows_map::Dict{String,Int} = Dict()
tunnels_map::Dict{String,Vector{String}} = Dict()
open("input.txt") do f
    while !eof(f)
        line = readline(f)
        valve, rate, ts = match(line_re, line)
        valve = String(valve)
        rate = parse(Int, rate)
        ts = [String(m.match) for m in eachmatch(r"([A-Z][A-Z])", ts)]
        flows_map[valve] = rate
        tunnels_map[valve] = ts
        # println("$valve, $rate, $ts")
    end
end

location_names::Vector{String} = Vector()
location_indexes::Dict{String,Int} = Dict()
flows::Vector{Int} = Vector()
tunnels::Vector{Vector{Int}} = Vector()
for (k, v) in flows_map
    push!(location_names, k)
    location_indexes[k] = length(location_names)
    push!(flows, v)
end

for i = 1:length(location_names)
    to = [location_indexes[n] for n in tunnels_map[location_names[i]]]
    push!(tunnels, to)
end

# Heuristic - assumes that we can reach all the remaining flows,
# in optimal order, with one turn travel in between
Base.@pure function max_left(flows::Vector{Int}, states::Vector{Int}, turn::Int)
    valves = [f for (f, s) in zip(flows, states) if f > 0 && s == 0] |> sort |> reverse
    total = 0
    for v in valves
        total += (v * turn)
        turn -= 2
        if turn < 0
            break
        end
    end
    return total
end

function find_max(flows::Vector{Int},
    tunnels::Vector{Vector{Int}},
    state::Vector{Int},
    position::Int,
    turn::Int,
    score::Int,
    max::Int)

    new_score = 0
    if turn == -1
        return 0
    end

    ml = max_left(flows, state, turn)
    if ml == 0
        return 0
    end
    if score + ml <= max
        return 0
    end

    if state[position] == 0 && flows[position] > 0
        # First search trying turning the valve
        # newstate = Dict((a, b) for (a, b) in state)
        newstate = [f for f in state]
        newstate[position] = 1
        vs = flows[position] * (turn - 1)
        s = find_max(flows, tunnels, newstate, position, turn - 1, score + vs, max)
        if vs + s > new_score
            new_score = vs + s
        end
        if score + new_score > max
            max = score + new_score
        end
    end
    # Now search travelling each tunnel
    # shuffle lessens going back-and-forth repeatedly
    # ~15% speedup
    for t in shuffle(tunnels[position])
        s = find_max(flows, tunnels, state, t, turn - 1, score, max)
        if s > new_score
            new_score = s
        end
        if score + new_score > max
            max = score + new_score
        end
    end
    return new_score
end

function find_max_p2(flows::Vector{Int},
    tunnels::Vector{Vector{Int}},
    state::Vector{Int},
    position::Int,
    elephant_position::Int,
    turn::Int,
    score::Int,
    max::Int,
    is_elephants_turn::Bool)

    new_score = 0
    if turn == -1
        return 0
    end
    ml = max_left(flows, state, turn)
    if ml == 0
        return 0
    end
    if score + ml <= max
        return 0
    end

    if is_elephants_turn
        pos = elephant_position
        newturn = turn - 1
    else
        pos = position
        newturn = turn
    end

    if state[pos] == 0 && flows[pos] > 0
        # First search trying turning the valve
        # newstate = Dict((a, b) for (a, b) in state)
        newstate = [f for f in state]
        newstate[pos] = 1
        vs = flows[pos] * (turn - 1)
        s = find_max_p2(flows, tunnels, newstate, position, elephant_position, newturn, score + vs, max, !is_elephants_turn)
        if vs + s > new_score
            new_score = vs + s
        end
        if score + new_score > max
            max = score + new_score
        end
    end
    # Now search travelling each tunnel
    # shuffle lessens going back-and-forth repeatedly
    # ~15% speedup
    for t in shuffle(tunnels[pos])
        if is_elephants_turn
            newp = position
            newep = t
        else
            newp = t
            newep = elephant_position
        end
        s = find_max_p2(flows, tunnels, state, newp, newep, newturn, score, max, !is_elephants_turn)
        if s > new_score
            new_score = s
        end
        if score + new_score > max
            max = score + new_score
        end
    end
    return new_score
end

init_state = [0 for f in flows]

result = find_max(flows, tunnels, init_state, location_indexes["AA"], 30, 0, 0)
println("Part 1: $result")

result = find_max_p2(flows, tunnels, init_state, location_indexes["AA"], location_indexes["AA"], 26, 0, 0, false)
println("Part 2: $result")