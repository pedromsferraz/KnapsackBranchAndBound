function backtracking_knapsack(n, B, v, w)
    function backtracking_knapsack_inner(i, q, value, weight)
        if i == 0
            return value
        end

        ans1 = backtracking_knapsack_inner(i-1, q, value, weight)
        ans2 = -Inf64
        if weight + w[i] <= q
            ans2 = backtracking_knapsack_inner(i-1, q, value + v[i], weight + w[i])
        end
        return max(ans1, ans2)
    end
    return backtracking_knapsack_inner(n, B, 0, 0)
end

# instance = generate_knapsack_inst(28)
# backtracking_knapsack(instance...)
