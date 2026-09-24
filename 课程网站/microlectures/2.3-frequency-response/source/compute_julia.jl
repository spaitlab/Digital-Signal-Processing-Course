open(joinpath(@__DIR__,"..","qa","julia.csv"),"w") do io
 println(io,"ratio,n,x,y,amp")
 for ratio in (.1,.2,.4,.6,.8)
  w=ratio*pi;x=cos.(w .* (0:79));H=sum(exp.(-im .* w .* (0:4)))/5
  for i in eachindex(x)
   y=sum(x[max(1,i-4):i])/5
   println(io,"$ratio,$(i-1),$(x[i]),$y,$(abs(H))")
  end
 end
end
println("JULIA_FREQUENCY_RESPONSE_OK ",VERSION)
