using Gurobi
using JuMP
m = Model(Gurobi.Optimizer)

J=3
H=10
T=3
zp = collect(200:10:220)

zc = collect(1000:500:2000)

D = [0.5  0.6   0.5; 
    2.0   2.0   1.2; 
    0.4   0.8    2.2]; #d_jt

d = [0.8   0.8  0.8; 2.4   1.2   1.32; 0.12  0.12  2.16];

@variable(m, 0 ≤ χ[1:H,1:J] ≤ 1 )
@variable(m, α[1:H,1:J,1:T], Bin)

@variable(m, 0 ≤ γ[1:J,1:T])

@objective(m, 
          Min, 
         sum( zp[j] * χ[h,j]  for j=1:J for h=1:H) +
         sum( zc[j] * γ[j,t] for j=1:J for t=1:T)
            )

@constraint(m, c1[h=1:H,j=1:J,t=1:T], α[h,j,t] ≤ 1000 * χ[h,j])

@constraint(m, c2[h=1:H,t=1:T], sum( α[h,j,t] for j=1:J ) ≤ 1)

#@constraint(m, c3[j=1:J, t=1:T], sum( α[h,j,t] * χ[h,j] for h=1:H ) ≥ D[j,t] )

@constraint(m, c3[j=1:J, t=1:T], sum( α[h,j,t] * χ[h,j] + γ[j,t] for h=1:H ) ≥ D[j,t] )

optimize!(m)
objective_value(m)

@expression(m,  ζT, sum( χ[h,j] for j=1:J for h=1:H ) )
@expression(m,  ζP, sum( χ[h,j] for j=1:J for h=1:H ) / (H * J) )
@expression(m,  ζh[h=1:H], sum( χ[h,j] for j=1:J )  )
@expression(m,  ζj[j=1:J], sum( χ[h,j] for h=1:H )  )

value(ζT)
value(ζP)
round.( JuMP.value.(ζh), digits= 2)
round.( JuMP.value.(ζj), digits= 2)


JuMP.value.(γ)