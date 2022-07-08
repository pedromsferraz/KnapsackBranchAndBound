include("dynamic_programming.jl")
include("backtracking.jl")
include("branch_and_bound.jl")

using JSON

function read_instance(filename)
    file = readchomp(filename);
    lines = split(file, r"\n")
    rows = split.(lines[1:end], r" +")
    n = parse(Int64, rows[1][1])
    B = parse(Int64, rows[1][2])
    name = rows[1][3]

    n_rows = length(rows)
    v = [parse.(Int64, rows[i][2]) for i in 2:n_rows]
    w = [parse.(Int64, rows[i][3]) for i in 2:n_rows]
    return name, n, B, v, w
end

function write_json(file::String, dict::Dict, ident = 4) 
    open(file, "w") do f
        JSON.print(f, dict, ident)
    end
    return file
end

filenames = ["instances/knap-2-$i.txt" for i in 1:80]
function run_tests(filenames)
    results = Dict()
    for (i, filename) in enumerate(filenames)
        name, n, B, v, w = read_instance(filename)
        println("$i/$(length(filenames)) Rodando instância $name")
        value, items, root_bound, largest_bound, optimal_solution_count, elapsed_time = branch_and_bound_knapsack(n, B, v, w; time_limit=300)
        results[name] = Dict()
        results[name]["objective_value"] = value
        results[name]["best_solution"] = items
        results[name]["is_optimal"] = value == largest_bound
        results[name]["root_bound"] = root_bound
        results[name]["largest_bound"] = largest_bound
        results[name]["solution_count"] = optimal_solution_count
        results[name]["elapsed_time"] = elapsed_time
        write_json("results.json", results)
        println("Melhor solução: $value - Maior bound: $largest_bound - Tempo de execução: $elapsed_time\n")
    end
end
run_tests(filenames)
