using DelimitedFiles
root=dirname(dirname(@__FILE__));t=range(-1,1,length=801)
rows=[]
for (fs,M) in [(12,12),(12,36),(12,120),(6,120)]
 n=-M:M;x=cos.(2pi*5 .*n./fs)
 for (i,tt) in enumerate(t)
  y=sum(x .*sinc.(fs*tt .-n));push!(rows,(fs,M,i-1,y))
 end
end
open(joinpath(root,"qa","julia.csv"),"w") do io
 println(io,"fs,M,index,y");for r in rows;println(io,join(r,","));end
end
println("Julia reconstruction completed")
