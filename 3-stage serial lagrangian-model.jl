using JuMP
using Gurobi


model = Model(Gurobi.Optimizer)

#parameters
n = 3
h = [1,1,1]
c = [1.64,1.64,1.64]
K = 1
lambda = [1,1,1]
sigma = [2,2,2]
M = 100
N = 100

#penalty terms
alpha = 10
beta = 10
gamma = 10
rho = 10
eta = 10
epsilon = 10
delta = 10

#Variables
@variable(model, ST[0:3] >= 0, Int)
@variable(model, z[1:3] >= 0, Int)
@variable(model, y[1,1:3] >= 0, Bin)
@variable(model, u[1:3] >= 0, Int)
@variable(model, H[1:3] >= 0, Int)
@variable(model, P[1,1:3] >= 0, Int)
@variable(model, Q >= 0, Int)
@variable(model, R10 >= 0, Int)
@variable(model, R21 >= 0, Int)
@variable(model, R32 >= 0, Int)
@variable(model, x10 >= 0, Bin)
@variable(model, x21 >= 0, Bin)
@variable(model, x32 >= 0, Bin)
@variable(model, U10 >= 0, Int)
@variable(model, U21 >= 0, Int)
@variable(model, U32 >= 0, Int)

#Objective
@objective(model, Min, sum(h[i]*c[i]*sigma[i]*z[i] for i in 1:n)
                        + alpha*sum((1 - sum(y[k,i] for k in 1:K))^2 for i in 1:n)
                        + beta*(u[1] - (lambda[1] - z[1]^2) - M*(1 - y[1,1]) + P[1,1])^2
                        + beta*(u[2] - (lambda[1] - z[1]^2 + lambda[2] - z[2]^2) + M*(1 - y[1,2]) + P[1,2])^2
                        + beta*(u[3] - (lambda[1] - z[1]^2 + lambda[2] - z[2]^2 + lambda[3] - z[3]^2) + M*(1 - y[1,3]) + P[1,3])^2
                        + gamma*(sum(lambda) - sum(z[i]^2 for i in 1:n) - ST[3] + Q)^2
                        + rho*(z[1]^2 - H[1] - lambda[1] + ST[1])^2
                        + rho*(z[2]^2 - H[2] - lambda[2] + ST[2])^2
                        + rho*(z[3]^2 - H[3] - lambda[3] + ST[3])^2
                        + eta*(ST[0] - H[1] + R10)^2
                        + eta*(ST[1] - H[2] + R21)^2
                        + eta*(ST[2] - H[3] + R32)^2
                        + epsilon*(H[1] - ST[0] - N*(1 - x10) + U10)^2
                        + epsilon*(H[2] - ST[1] - N*(1 - x21) + U21)^2
                        + epsilon*(H[3] - ST[2] - N*(1 - x32) + U32)^2
                        + delta*(1 - x10)^2
                        + delta*(1 - x21)^2
                        + delta*(1 - x32)^2
)

#Fake constraints
@constraint(model, ST[3] == 1)
@constraint(model, ST[0] == 0)
@constraint(model, z[1] == 1)
@constraint(model, z[2] == 1)
@constraint(model, z[3] == 0)

# print(objective_function(model))
optimize!(model)

println("Results: ", objective_value(model))
println("z1 = ", value(z[1]))
println("z2 = ", value(z[2]))
println("z3 = ", value(z[3]))
for i in 0:3
    println("ST[$i]: ", value(ST[i]))
end
for i in 1:3
    println("H[$i]: ", value(H[i]))
end
for k in 1:K
    for i in 1:n
        println("P[$k,$i]: ", value(P[k,i]))
    end
end
println("Q: ", value(Q))
println("R10: ", value(R10))
println("R21: ", value(R21))
println("R32: ", value(R32))
