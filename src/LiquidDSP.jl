module LiquidDSP

include("../deps/deps.jl")

realtype(x::DataType) = x
realtype{T}(::Type{Complex{T}}) = T
complextype(T::DataType) = Complex{T}
complextype{T}(::Type{Complex{T}}) = Complex{T}

const rrrf = ("rrrf", Float32,Float32,Float32)
const crcf = ("crcf", Complex64,Float32,Complex64)
const cccf = ("cccf", Complex64,Complex64,Complex64)

include("Filter/filter.jl")

end # module
