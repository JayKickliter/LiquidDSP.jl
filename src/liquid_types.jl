immutable FIRFiltType
    kind::Cint
end

const unknown   = FIRFiltType(0 )   # LIQUID_FIRFILT_UNKNOWN    unknown filter type
const kaiser    = FIRFiltType(1 )   # LIQUID_FIRFILT_KAISER     Nyquist Kaiser filter
const pm        = FIRFiltType(2 )   # LIQUID_FIRFILT_PM         Parks-McClellan filter
const rcos      = FIRFiltType(3 )   # LIQUID_FIRFILT_RCOS       raised-cosine filter
const fexp      = FIRFiltType(4 )   # LIQUID_FIRFILT_FEXP       flipped exponential
const fsech     = FIRFiltType(5 )   # LIQUID_FIRFILT_FSECH      flipped hyperbolic secant
const farcsech  = FIRFiltType(6 )   # LIQUID_FIRFILT_FARCSECH   flipped arc-hyperbolic secant
const arkaiser  = FIRFiltType(7 )   # LIQUID_FIRFILT_ARKAISER   root-Nyquist Kaiser (approximate optimum)
const rkaiser   = FIRFiltType(8 )   # LIQUID_FIRFILT_RKAISER    root-Nyquist Kaiser (true optimum)
const rrc       = FIRFiltType(9 )   # LIQUID_FIRFILT_RRC        root raised-cosine
const hm3       = FIRFiltType(10)   # LIQUID_FIRFILT_hM3        harris-Moerder-3 filter
const gmsktx    = FIRFiltType(11)   # LIQUID_FIRFILT_GMSKTX     GMSK transmit filter
const gmskrx    = FIRFiltType(12)   # LIQUID_FIRFILT_GMSKRX     GMSK receive filter
const rfexp     = FIRFiltType(13)   # LIQUID_FIRFILT_RFEXP      flipped exponential
const rfsech    = FIRFiltType(14)   # LIQUID_FIRFILT_RFSECH     flipped hyperbolic secant
const rfarcsech = FIRFiltType(15)   # LIQUID_FIRFILT_RFARCSECH  flipped arc-hyperbolic secant
































