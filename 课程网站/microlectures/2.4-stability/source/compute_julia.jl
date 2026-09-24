root=dirname(dirname(@__FILE__))
open(joinpath(root,"qa","julia.csv"),"w") do io
 println(io,"id,n,h,y")
 for a in [.8,1.,1.2]
  y=0.;for n=0:127;y=1+a*y;println(io,"a$(a),$n,$(a^n),$y");end
 end
 y=0.;for n=0:127;h=1/(n+1);y+=h;println(io,"harmonic,$n,$h,$y");end
end
println("Julia stability examples completed")
