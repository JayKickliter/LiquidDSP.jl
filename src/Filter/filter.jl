include("firfilt.jl")
export  FIRFilter,
        destroy,
        print,
        reset!,
        execute,
        push!,
        freqresponse,
        groupdelay

include("firinterp.jl")
export FIRInterp
