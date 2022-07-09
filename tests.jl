using Distributed
addprocs(8)

@everywhere include("dynamic_programming.jl")
@everywhere include("backtracking.jl")
@everywhere include("branch_and_bound.jl")

@everywhere begin
    using JSON, DataFrames

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
    function run_tests(i, filename)
        results = Dict()
        N = length(filenames)
        name, n, B, v, w = read_instance(filename)
        println("$i / $N Rodando instância $name")
        value, items, root_bound, largest_bound, optimal_solution_count, elapsed_time = branch_and_bound_knapsack(n, B, v, w; time_limit=3600)
        results[name] = Dict()
        results[name]["objective_value"] = value
        results[name]["best_solution"] = items
        results[name]["is_optimal"] = value == largest_bound
        results[name]["root_bound"] = root_bound
        results[name]["largest_bound"] = largest_bound
        results[name]["solution_count"] = optimal_solution_count
        results[name]["elapsed_time"] = elapsed_time
        write_json("results_machine_$i.json", results)
        println("Melhor solução: $value - Maior bound: $largest_bound - Tempo de execução: $elapsed_time\n")
    end
end
pmap(x -> run_tests(x...), collect(enumerate(filenames)))

function read_results(file::String)
    results_json = JSON.parse(String(read(file)))
    result_key = collect(keys(results_json))[1]
    
    df_results = DataFrame()
    for result_key in collect(keys(results_json))
        dict_keys = ["objective_value", "is_optimal", "elapsed_time", "root_bound", "largest_bound", "solution_count"]
        key_value_pairs = ["name" => result_key, [value_key => results_json[result_key][value_key] for value_key in dict_keys]...]
        df = DataFrame(key_value_pairs)
        append!(df_results, df)
    end
    return df_results
end
