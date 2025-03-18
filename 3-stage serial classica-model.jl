using JuMP
using Gurobi


model = Model(Gurobi.Optimizer)

    #parameters
n = 3
h = [1,1,1]
k = [1.64,1.64,1.64]
lambda = [1,1,1]
sigma = [2,2,2]
M = 10
N = 10

#Variables
@variable(model, ST[0:3] >= 0, Int)
@variable(model, z[1:3] >= 0, Int)
@variable(model, y11 >= 0, Bin)
@variable(model, y12 >= 0, Bin)
@variable(model, y13 >= 0, Bin)
@variable(model, x10 >= 0, Bin)
@variable(model, x21 >= 0, Bin)
@variable(model, x32 >= 0, Bin)
@variable(model, u[1:3] >= 0, Int)
@variable(model, H[1:3] >= 0, Int)

#Objective
@objective(model, Min, sum(h[i]*k[i]*sigma[i]*z[i] for i in 1:n))

#Constraints
@constraint(model, u[1] <= lambda[1] - z[1]^2 + M*(1-y11))
@constraint(model, y11 >= 1)
@constraint(model, u[2] <= lambda[1] - z[1]^2 + lambda[2] - z[2]^2 + M*(1-y12))
@constraint(model, y12 >= 1)
@constraint(model, u[3] <= lambda[1] - z[1]^2 + lambda[2] - z[2]^2 + lambda[3] - z[3]^2 + M*(1-y13))
@constraint(model, y13 >= 1)
@constraint(model, z[1]^2 + z[2]^2 + z[3]^2 >= sum(lambda) - ST[3])

@constraint(model, z[1]^2 == H[1] + lambda[1] - ST[1])
@constraint(model, H[1] >= ST[0])
@constraint(model, H[1] - ST[0] - N*(1 - x10) <= 0)
@constraint(model, x10 >= 1)

@constraint(model, z[2]^2 == H[2] + lambda[2] - ST[2])
@constraint(model, H[2] >= ST[1])
@constraint(model, H[2] - ST[1] - N*(1 - x21) <= 0)
@constraint(model, x21 >= 1)

@constraint(model, target, z[3]^2 == H[3] + lambda[3] - ST[3])
@constraint(model, H[3] >= ST[2])
@constraint(model, H[3] - ST[2] - N*(1 - x32) <= 0)
@constraint(model, x32 >= 1)


#Additional constraints
@constraint(model, ST[0] == 0)
@constraint(model, ST[3] == 1)


print(model)

optimize!(model)

println("Results: ", objective_value(model))
println("z1 = ", value(z[1]))
println("z2 = ", value(z[2]))
println("z3 = ", value(z[3]))
for i in 0:3
    println("ST[$i] = ", value(ST[i]))
end
for i in 1:3
    println("H[$i] = ", value(H[i]))
end
println("target: ", model[:target])