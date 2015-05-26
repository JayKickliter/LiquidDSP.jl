module LiquidDSP

push!(Base.DL_LOAD_PATH, "/opt/local/lib")

const rrrf = ("rrrf", Float32,Float32,Float32)
const crcf = ("crcf", Complex64,Float32,Complex64)
const cccf = ("cccf", Complex64,Complex64,Complex64)

@unix_only const libliquid = "libliquid"

macro liquidcall(lqiuidf, returntype, argtypes, args...)
    quote
        ret = ccall(($liquidf, libliquid), $returntype, $argtypes, $(args...))
    end
end



include("filter/filter.jl")

end # module
