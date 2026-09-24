# 与MATLAB同参数的独立Julia对照；不依赖工具箱。
out=joinpath(@__DIR__,"..","qa","julia.csv")
open(out,"w") do io
 println(io,"fs,bits,n,x,q,y")
 for fs in (16,32), bits in (3,8)
  L=2^bits;delta=2/L
  for n in 0:fs-1
   x=.72*sin(2pi*n/fs)+.18*cos(6pi*n/fs)
   code=clamp(floor(Int,(x+1)/delta),0,L-1);q=-1+(code+.5)*delta
   @assert abs(q-x)<=delta/2+1e-12
   println(io,"$fs,$bits,$n,$x,$q,$(.5*x)")
  end
 end
end
println("JULIA_SAMPLING_QUANTIZATION_OK")
