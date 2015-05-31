module LiquidDSP

const rrrf = ("rrrf", Float32,Float32,Float32)
const crcf = ("crcf", Complex64,Float32,Complex64)
const cccf = ("cccf", Complex64,Complex64,Complex64)

include("../deps/deps.jl")
include("util.jl")
include("liquid_types.jl")

include("Filter/filter.jl")

end # module
