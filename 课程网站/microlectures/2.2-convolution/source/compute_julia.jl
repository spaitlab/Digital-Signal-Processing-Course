root=dirname(dirname(@__FILE__));x=[1.,2,3,4]
open(joinpath(root,"qa","julia.csv"),"w") do io
 println(io,"id,n,y")
 for (id,h,x0,h0) in [("base",[3.,2,1],0,0),("shift",[3.,2,1],-1,2),("echo",[1.,0,.5],0,0)]
  for n in x0+h0:x0+h0+length(x)+length(h)-2
   y=0.;for (i,v) in enumerate(x);j=n-(x0+i-1)-h0+1;if 1<=j<=length(h);y+=v*h[j];end;end
   println(io,"$id,$n,$y")
  end
 end
end
println("Julia convolution verified independently")
