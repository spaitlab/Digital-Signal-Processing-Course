open(joinpath(@__DIR__,"..","qa","julia.csv"),"w") do io
 println(io,"N,A,start,n,x,energy")
 for N in (200,180), A in (1,.5), start in (0,1)
  n=start .+ (0:N-1);x=A .* sin.(2pi .* 2 .* n ./ 100);E=sum(x .^ 2)
  for i in eachindex(x)
   println(io,"$N,$A,$start,$(n[i]),$(x[i]),$E");end
 end
end
println("JULIA_TOOLS_OK ",VERSION)
