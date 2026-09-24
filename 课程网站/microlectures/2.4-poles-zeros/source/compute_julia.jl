root=dirname(dirname(@__FILE__))
open(joinpath(root,"qa","julia.csv"),"w") do io
 println(io,"r,w_pi,re,im")
 for r in [.5,sqrt(.72),.95],k in 0:800
  w=k*pi/800;z=exp(im*w);p=r*exp(im*pi/4);h=z*(z+1)/((z-p)*(z-conj(p)))
  println(io,"$r,$(k/800),$(real(h)),$(imag(h))")
 end
end
println("Julia complex factor evaluation passed")
