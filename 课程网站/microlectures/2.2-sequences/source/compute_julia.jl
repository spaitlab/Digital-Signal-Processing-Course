open(joinpath(@__DIR__,"..","qa","julia.csv"),"w") do io
 println(io,"id,shift,n,x,shifted")
 for id in ("pi","rad"), shift in (7,20,21,40), n in 0:119
  w=id=="pi" ? .3pi : .3;x=cos(w*n);y=cos(w*(n+shift))
  println(io,"$id,$shift,$n,$x,$y")
 end
end
println("JULIA_SEQUENCES_OK ",VERSION)
