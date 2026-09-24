open(joinpath(@__DIR__,"..","qa","julia.csv"),"w") do io
 println(io,"fs,kind,n,x")
 for fs in (20,12,6,10), kind in ("cos","sin"), n in 0:fs
  x=(kind=="cos" ? cos : sin)(2pi*5*n/fs)
  println(io,"$fs,$kind,$n,$x")
 end
end
println("JULIA_SAMPLING_OK ",VERSION)
