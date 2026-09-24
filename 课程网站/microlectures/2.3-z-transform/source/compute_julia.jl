root=dirname(dirname(@__FILE__));a=.8
open(joinpath(root,"qa","julia.csv"),"w") do io
 println(io,"side,r,angle,N,re,im")
 for side in ["right","left"],r in [.4,.8,1.,1.2],angle in [0,1]
  z=r*exp(im*(angle*pi/3));s=0.0+0im
  for N=1:40
   n=side=="right" ? N-1 : -N;s+=(side=="right" ? 1 : -1)*a^n*z^(-n);println(io,"$side,$r,$angle,$N,$(real(s)),$(imag(s))")
  end
 end
end
println("Julia z-transform partial sums completed")
