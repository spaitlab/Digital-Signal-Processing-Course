# FIR-01: TyMath is preferred according to installed Syslab skill policy.
# Absolute paths / @__DIR__; no change to persistent session directory.
using TyMath
using DelimitedFiles
using Printf
function run_fir01()
    root = @__DIR__
    data = readdlm(joinpath(root, "results", "input.csv"), ',', Float64; skipstart=1)
    @assert size(data) == (2001, 2)
    b = fill(0.25, 4)
    y, _ = TyMath.filter1(b, [1.0], data[:,2])
    impulse, _ = TyMath.filter1(b, [1.0], [1.0; zeros(7)])
    @assert maximum(abs.(vec(impulse) - [b; zeros(4)])) < 1e-15
    step, _ = TyMath.filter1(b, [1.0], ones(8))
    @assert maximum(abs.(vec(step) - [0.25,0.5,0.75,1,1,1,1,1])) < 1e-15
    open(joinpath(root, "results", "syslab.csv"), "w") do io
        println(io, "t,x,y")
        for i in axes(data,1)
            @printf(io, "%.17g,%.17g,%.17g\n", data[i,1],data[i,2],y[i])
        end
    end
    open(joinpath(root, "results", "syslab-runtime.txt"), "w") do io
        println(io, "Julia=", VERSION)
        println(io, "TyMath=", pkgversion(TyMath))
        println(io, "method=TyMath.filter1; zero initial state; 2 local checks passed")
    end
    println("FIR01_SYSLAB_PASSED; samples=",length(y))
end
run_fir01()
