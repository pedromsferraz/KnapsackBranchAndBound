function generate_knapsack_inst(n)    
    value = zeros(n+1)
    weight = zeros(n+1)
    
    infty = 0
    for i in 1:n+1
        value[i] = rand(10:40)
        weight[i] = rand(1:12)
        infty += value[i]
    end

    B = rand(2*n:4*n)
    return n, B, value, weight
end

# V[i, q] -> valor máximo da mochila considerando itens {1, 2, ..., i} dado que a mochila fica com peso exatamente q

# implementação top-down
function knapsack(n, B, v, w)
    dp_dict = Dict()

    function knapsack_dp(i, q)
        # Caso base
        if i == 0
            if q != 0
                return -Inf64
            else
                return 0
            end
        end

        # Evita recomputar instâncias
        if haskey(dp_dict, (i, q))
            return dp_dict[i, q]
        end

        # Calcula valor máximo para essa instância
        if (q - w[i] >= 0)
            dp_dict[i, q] = max(knapsack_dp(i-1, q), knapsack_dp(i-1, q-w[i]) + v[i])
        else
            dp_dict[i, q] = knapsack_dp(i-1, q)
        end
        return dp_dict[i, q]
    end

    for q in 1:B
        knapsack_dp(n, q)
    end
    return dp_dict
end

# implementação bottom-up
function knapsack_bottom_up(n, B, v, w)
    dp_dict = Dict()

    for q in 1:B
        dp_dict[0, q] = -Inf64
    end
    dp_dict[0, 0] = 0

    for i in 1:n
        for q in 0:B
            dp_dict[i, q] = dp_dict[i-1, q]
            if q >= w[i]
                dp_dict[i, q] = max(dp_dict[i-1, q], dp_dict[i-1, q-w[i]] + v[i])
            end
        end
    end

    return dp_dict
end

# instance = generate_knapsack_inst(500)
# dp_dict1, time1 = @timed knapsack(instance...)
# dp_dict2, time2 = @timed knapsack_bottom_up(instance...)

# time1, time2
# maximum(values(dp_dict1)) ≈ maximum(values(dp_dict2))
