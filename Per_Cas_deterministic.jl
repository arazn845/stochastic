using Gurobi
using JuMP
m = Model(Gurobi.Optimizer)

J=3
H=10
T=3
zp = collect(200:10:220)

zc = collect(1000:500:2000)

#average
D = [0.5  0.6   0.5; 2.0   2.0   1.2; 0.4   0.8    2.2]; #d_jt

#above average
D = [0.8  0.9   0.8; 2.5   2.5   1.8; 0.6   1.2    3.2]; #d_jt

#below average
D = [0.2  0.3   0.2; 1.5   1.5   0.8; 0.2   0.4    1.2]; #d_jt

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

@expression(m,  ζ_Permanent_Total, sum( χ[h,j] for j=1:J for h=1:H ) )
@expression(m,  ζ_Permanent_percentage, sum( χ[h,j] for j=1:J for h=1:H ) / (H * J) )
@expression(m,  ζ_Permanent_h[h=1:H], sum( χ[h,j] for j=1:J )  )
@expression(m,  ζ_Permanent_j[j=1:J], sum( χ[h,j] for h=1:H )  )



@expression(m,  ζ_Casual_Total, sum( γ[j,t] for j=1:T for t=1:T )  )
@expression(m,  ζ_Casual_j[j=1:J], sum( γ[j,t] for t=1:T )  )

df = DataFrame( objective_value = objective_value(m) )
df = DataFrame( ζ_Permanent_Total = value(ζ_Permanent_Total) )
df = DataFrame( ζ_Permanent_percentage = value(ζ_Permanent_percentage) )
df = DataFrame( ζ_Permanent_h = round.( JuMP.value.(ζ_Permanent_h), digits= 2) )
df = DataFrame( ζ_Permanent_j = round.( JuMP.value.(ζ_Permanent_j), digits= 2) )
##########################
df = DataFrame( ζ_Casual_Total = value(ζ_Casual_Total) )
df = DataFrame( ζ_Casual_j = round.( JuMP.value.(ζ_Casual_j), digits= 2) )


    
            

using CSV
using DataFrames
df = DataFrame( round.( JuMP.value.(χ), digits=2 ), :auto )
df = DataFrame( JuMP.value.(α[:, :,1]), :auto )
df = DataFrame( JuMP.value.(α[:, :,2]), :auto )
df = DataFrame( JuMP.value.(α[:, :,3]), :auto )


