
include("firfilt.jl")
export  FIRFilter

include("firinterp.jl")
export  FIRInterp

include("firdecim.jl")
export  FIRDecim,
        gettaps
        
include("resamp.jl")
export  Resamp

# Export common methods
export  destroy,
        print,
        reset!,
        execute,
        push!,
        freqresponse,
        groupdelay
