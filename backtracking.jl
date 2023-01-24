# Implementação que percorre todas as 2^n combinações de itens e retorna a de maior valor
function backtracking_knapsack_complete(n, B, v, w)
    function backtracking_knapsack_inner(i, value, weight)
        if i == 0
            if weight <= B
                return value
            else
                return 0
            end
        end

        ans1 = backtracking_knapsack_inner(i-1, value, weight)
        ans2 = backtracking_knapsack_inner(i-1, value + v[i], weight + w[i])
        return max(ans1, ans2)
    end
    return backtracking_knapsack_inner(n, 0, 0)
end

# Implementação que percorre apenas as combinações viáveis
function backtracking_knapsack_feasible(n, B, v, w)
    function backtracking_knapsack_inner(i, q, value, weight)
        if i == 0
            return value
        end

        ans1 = backtracking_knapsack_inner(i-1, q, value, weight)
        ans2 = 0
        if weight + w[i] <= q
            ans2 = backtracking_knapsack_inner(i-1, q, value + v[i], weight + w[i])
        end
        return max(ans1, ans2)
    end
    return backtracking_knapsack_inner(n, B, 0, 0)
end
