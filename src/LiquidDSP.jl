module LiquidDSP

include("../deps/deps.jl")

const rrrf = ("rrrf", Float32,Float32,Float32)
const crcf = ("crcf", Complex64,Float32,Complex64)
const cccf = ("cccf", Complex64,Complex64,Complex64)

include("Filter/filter.jl")

end # module
