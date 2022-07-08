using CPUTime

function greedy_knapsack(n, B, v, w)
    sorted_items = sort([(v[i] / w[i], i) for i in 1:n], rev=true)
    capacity = B
    value = 0
    items = Int64[]
    for j in 1:n
        _, i = sorted_items[j]
        if w[i] <= capacity
            value += v[i]
            capacity -= w[i]
            push!(items, i)
        end
    end
    return items
end

function fractional_knapsack(n, B, v, w)
    sorted_items = sort([(v[i] / w[i], i) for i in 1:n], rev=true)
    capacity = B
    value = 0
    for j in 1:n
        _, i = sorted_items[j]
        if w[i] <= capacity
            value += v[i]
            capacity -= w[i]
        else
            value += v[i] * (capacity / w[i])
            return value
        end
    end
    return value
end

function fractional_knapsack_items(items, B, v, w, initial_value, initial_weight, sorted_density)
    capacity = B - initial_weight
    value = initial_value
    for sorted_item in sorted_density
        _, i = sorted_item
        if i in items
            continue
        end
        if w[i] <= capacity
            value += v[i]
            capacity -= w[i]
        else
            value += v[i] * (capacity / w[i])
            return value
        end
    end
    return value
end

function branch_and_bound_knapsack_naive(n, B, v, w)
    current_max_value = -Inf64

    function branch_and_bound_inner(i, value, weight)
        current_max_value = max(current_max_value, value)
        if i == 0
            return value
        end

        # Calcula limite superior via mochila fracionário
        upper_bound = floor(Int64, value + fractional_knapsack(i, B, v, w))
        if upper_bound <= current_max_value
            return current_max_value
        end

        # Caso não consiga podar, ramifica
        ans1 = branch_and_bound_inner(i-1, value, weight)
        ans2 = -Inf64
        if weight + w[i] <= B
            ans2 = branch_and_bound_inner(i-1, value + v[i], weight + w[i])
        end
        return max(ans1, ans2)
    end
    return branch_and_bound_inner(n, 0, 0)
end

function branch_and_bound_knapsack(n, B, v, w; time_limit=Inf64)
    t0 = time()

    greedy = greedy_knapsack(n, B, v, w)
    current_max_value = sum(v[greedy])
    current_best_solution = greedy
    optimal_solution_count = 0

    largest_upper_bound = -Inf64
    root_upper_bound = -Inf64

    sorted_density = sort([(v[i] / w[i], i) for i in 1:n], rev=true)
    sorted_items = map(item -> item[2], sorted_density)

    should_print_tle = true
    function branch_and_bound_inner(i, items, value, weight)
        if value > current_max_value
            current_max_value = value
            current_best_solution = items
            optimal_solution_count = 1
        elseif value == current_max_value && sort(items) != sort(current_best_solution)
            optimal_solution_count += 1
        end
        if i == n+1
            return value, items
        end

        # Calcula limite superior via mochila fracionário
        upper_bound = floor(Int64, fractional_knapsack_items(items, B, v, w, value, weight, sorted_density[i:end]))
        if i == 1
            root_upper_bound = upper_bound
        end
        if upper_bound <= current_max_value
            return current_max_value, current_best_solution
        end
        
        # Checa se o tempo limite foi excedido
        t1 = time()
        if t1 - t0 > time_limit
            if should_print_tle
                println("Tempo limite excedido.")
                should_print_tle = false
            end
            largest_upper_bound = max(largest_upper_bound, upper_bound)
            return current_max_value, current_best_solution
        end

        # Caso não consiga podar, ramifica 
        current_item = sorted_items[i]
        ans1 = -Inf64
        if weight + w[current_item] <= B
            new_items = copy(items)
            push!(new_items, current_item)
            ans1, items1 = branch_and_bound_inner(i+1, new_items, value + v[current_item], weight + w[current_item])
        end
        ans2, items2 = branch_and_bound_inner(i+1, items, value, weight)
        
        if ans1 >= ans2
            return ans1, items1
        else
            return ans2, items2
        end
    end
    if largest_upper_bound == -Inf64
        largest_upper_bound = current_max_value
        optimal_solution_count = max(1, optimal_solution_count)
    end
    t1 = time()
    return branch_and_bound_inner(1, [], 0, 0)..., root_upper_bound, largest_upper_bound, optimal_solution_count, t1 - t0
end

# n, B, v, w = generate_knapsack_inst(3)
# v = v[1:n]
# w = w[1:n]
# value, items, root_bound, largest_bound, optimal_solution_count, elapsed_time = branch_and_bound_knapsack(n, B, v, w)
