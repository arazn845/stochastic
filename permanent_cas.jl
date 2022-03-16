using CPLEX
using JuMP
m = Model(CPLEX.Optimizer); 

#parameters
J=3
H=5
T=3
zp = collect(200:10:220)
D = [0.6   0.36  0.12;2.4   1.2   1.32;0.12  0.12  2.16]; 

#variables
@variable(m, 0 ≤ χ[1:H,1:J] ≤ 1 )
@variable(m, α[1:H,1:J,1:T], Bin)
@variable(m,0 ≤ z1[1:H,1:J,1:T] );

#objective
@objective(m, 
          Min, 
         sum( zp[j] * χ[h,j]  for j=1:J, h=1:H) 
         )

#constraint
@constraint(m, c1[h=1:H,j=1:J,t=1:T], α[h,j,t] ≤ 1000 * χ[h,j])

@constraint(m, c2[h=1:H,t=1:T], sum( α[h,j,t] for j=1:J ) ≤ 1)

@constraint(m, c_linear_2[h=1:H, j=1:J, t=1:T], z1[h,j,t] ≤ χ[h,j])
@constraint(m, c_linear_3[h=1:H, j=1:J, t=1:T], z1[h,j,t] ≥ χ[h,j] - (1-α[h,j,t]) )
@constraint(m, c3[j=1:J, t=1:T], sum( z1[h,j,t] for h=1:H ) ≥ D[j,t] );  

optimize!(m)
objective_value(m)
