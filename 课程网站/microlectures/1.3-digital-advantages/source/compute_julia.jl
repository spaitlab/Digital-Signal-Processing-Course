function quant(x,b)
 d=2/2^b;r=(x+1)/d;r=abs(r-round(r))<1e-10 ? round(r) : r
 -1+(clamp(floor(Int,r),0,2^b-1)+.5)*d
end
open(joinpath(@__DIR__,"..","qa","julia.csv"),"w") do io
 println(io,"bits,gain,n,q,stored")
 for b in (3,8), g in (.5,1,2), n in 0:31
  x=.72sin(2pi*n/32)+.18cos(6pi*n/32);q=quant(x,b);y=quant(g*q,b)
  println(io,"$b,$g,$n,$q,$y")
 end
end
println("JULIA_ADVANTAGES_OK")
