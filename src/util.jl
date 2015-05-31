realtype(x::DataType)           = x
realtype{T}(::Type{Complex{T}}) = T

complextype(T::DataType)           = Complex{T}
complextype{T}(::Type{Complex{T}}) = Complex{T}

limitprecision(x)                     = x
limitprecision(x::Float64)            = Float32(x)
limitprecision(x::Complex128)         = Complex64(x)
limitprecision(x::Vector{Float64})    = convert(Vector{Float32}, x)
limitprecision(x::Vector{Complex128}) = convert(Vector{Complex64}, x)
limitprecision{T}(::Type{T})          = T
limitprecision(::Type{Float64})       = Float32
limitprecision(::Type{Complex128})    = Complex64
