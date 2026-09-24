open(joinpath(@__DIR__,"..","qa","julia.csv"),"w") do io
 println(io,"M,n,q,y")
 x=[sin(2pi*2*n/100)+.5*sin(2pi*15*n/100) for n in 0:199]
 scaled=(x .+ 2)./(4/256)
 scaled=[abs(v-round(v))<1e-10 ? round(v) : v for v in scaled]
 q=[-2+(clamp(floor(Int,v),0,255)+.5)*(4/256) for v in scaled]
 for M in (1,3,5,9), i in eachindex(q)
  y=sum(q[max(1,i-M+1):i])/M
  println(io,"$M,$(i-1),$(q[i]),$y")
 end
end
println("JULIA_DSP_CHAIN_OK")
