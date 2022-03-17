using Gurobi
using JuMP
m = Model(Gurobi.Optimizer)

J=3
H=10
T=3
S=3
zp = collect(200:10:220)

zc = collect(1000:500:2000)


#D_jts
D =cat( dims = 3, 
 [0.5  0.6   0.5; 2.0   2.0   1.2; 0.4   0.8    2.2],
 [0.8  0.9   0.8; 2.5   2.5   1.8; 0.6   1.2    3.2],
 [0.2  0.3   0.2; 1.5   1.5   0.8; 0.2   0.4    1.2])

@variable(m, 0 ≤ χ[1:H,1:J] ≤ 1 )
@variable(m, α[1:H,1:J,1:T,1:S], Bin)

#@variable(m, 0 ≤ γ[1:J,1:T])
@variable(m, 0 ≤ γ[1:J,1:T,1:S])

@objective(m, 
          Min, 
         sum( zp[j] * χ[h,j]  for j=1:J for h=1:H) +
         #sum( zc[j] * γ[j,t] for j=1:J for t=1:T)
          0.33 *  sum( zc[j] * γ[j,t,s] for j=1:J for t=1:T for s=1:S )
            )



@constraint(m, c1[h=1:H,j=1:J,t=1:T, s=1:S], α[h,j,t,s] ≤ 1000 * χ[h,j])

@constraint(m, c2[h=1:H, t=1:T, s=1:S], sum( α[h,j,t,s] for j=1:J ) ≤ 1)

#@constraint(m, c3[j=1:J, t=1:T], sum( α[h,j,t] * χ[h,j] for h=1:H ) ≥ D[j,t] )

@constraint(m, c3[j=1:J, t=1:T, s=1:S], sum( α[h,j,t,s] * χ[h,j] + γ[j,t,s] for h=1:H ) ≥ D[j,t,s] )

optimize!(m)
objective_value(m)

@expression(m,  ζ_Permanent_Total, sum( χ[h,j] for j=1:J for h=1:H ) )
@expression(m,  ζ_Permanent_percentage, sum( χ[h,j] for j=1:J for h=1:H ) / (H * J) )
@expression(m,  ζ_Permanent_h[h=1:H], sum( χ[h,j] for j=1:J )  )
@expression(m,  ζ_Permanent_j[j=1:J], sum( χ[h,j] for h=1:H )  )

value(ζ_Permanent_Total)
value(ζ_Permanent_percentage)
round.( JuMP.value.(ζ_Permanent_h), digits= 2)
round.( JuMP.value.(ζ_Permanent_j), digits= 2)
##########################




JuMP.value.(γ)

using CSV
using DataFrames
df = DataFrame( round.( JuMP.value.(χ), digits=2 ), :auto )
df = DataFrame( JuMP.value.(α[:, :,1]), :auto )
df = DataFrame( JuMP.value.(α[:, :,2]), :auto )
df = DataFrame( JuMP.value.(α[:, :,3]), :auto )
