module LiquidDSP

using BinDeps
@BinDeps.load_dependencies

const rrrf = ("rrrf", Float32,Float32,Float32)
const crcf = ("crcf", Complex64,Float32,Complex64)
const cccf = ("cccf", Complex64,Complex64,Complex64)

include("filter/filter.jl")

end # module
