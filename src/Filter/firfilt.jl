# FIRFILT() FIRFILT(_create)(TC * _h, unsigned int _n);           \
#                                                                 \
# /* create using Kaiser-Bessel windowed sinc method          */  \
# /*  _n      : filter length, _n > 0                         */  \
# /*  _fc     : filter cut-off frequency 0 < _fc < 0.5        */  \
# /*  _As     : filter stop-band attenuation [dB], _As > 0    */  \
# /*  _mu     : fractional sample offset, -0.5 < _mu < 0.5    */  \
# FIRFILT() FIRFILT(_create_kaiser)(unsigned int _n,              \
#                                   float        _fc,             \
#                                   float        _As,             \
#                                   float        _mu);            \
#                                                                 \
# /* create from square-root Nyquist prototype                */  \
# /*  _type   : filter type (e.g. LIQUID_FIRFILT_RRC)         */  \
# /*  _k      : nominal samples/symbol, _k > 1                */  \
# /*  _m      : filter delay [symbols], _m > 0                */  \
# /*  _beta   : rolloff factor, 0 < beta <= 1                 */  \
# /*  _mu     : fractional sample offset,-0.5 < _mu < 0.5     */  \
# FIRFILT() FIRFILT(_create_rnyquist)(int          _type,         \
#                                     unsigned int _k,            \
#                                     unsigned int _m,            \
#                                     float        _beta,         \
#                                     float        _mu);          \
#                                                                 \
# /* re-create filter                                         */  \
# /*  _q      : original filter object                        */  \
# /*  _h      : pointer to filter coefficients [size: _n x 1] */  \
# /*  _n      : filter length, _n > 0                         */  \
# FIRFILT() FIRFILT(_recreate)(FIRFILT()    _q,                   \
#                              TC *         _h,                   \
#                              unsigned int _n);                  \
#                                                                 \
# /* destroy filter object and free all internal memory       */  \
# void FIRFILT(_destroy)(FIRFILT() _q);                           \
#                                                                 \
# /* reset filter object's internal buffer                    */  \
# void FIRFILT(_reset)(FIRFILT() _q);                             \
#                                                                 \
# /* print filter object information                          */  \
# void FIRFILT(_print)(FIRFILT() _q);                             \
#                                                                 \
# /* set output scaling for filter                            */  \
# void FIRFILT(_set_scale)(FIRFILT() _q,                          \
#                          TC        _scale);                     \
#                                                                 \
# /* push sample into filter object's internal buffer         */  \
# /*  _q      : filter object                                 */  \
# /*  _x      : single input sample                           */  \
# void FIRFILT(_push)(FIRFILT() _q,                               \
#                     TI        _x);                              \
#                                                                 \
# /* execute the filter on internal buffer and coefficients   */  \
# /*  _q      : filter object                                 */  \
# /*  _y      : pointer to single output sample               */  \
# void FIRFILT(_execute)(FIRFILT() _q,                            \
#                        TO *      _y);                           \
#                                                                 \
# /* execute the filter on a block of input samples; the      */  \
# /* input and output buffers may be the same                 */  \
# /*  _q      : filter object                                 */  \
# /*  _x      : pointer to input array [size: _n x 1]         */  \
# /*  _n      : number of input, output samples               */  \
# /*  _y      : pointer to output array [size: _n x 1]        */  \
# void FIRFILT(_execute_block)(FIRFILT()    _q,                   \
#                              TI *         _x,                   \
#                              unsigned int _n,                   \
#                              TO *         _y);                  \
#                                                                 \
# /* return length of filter object                           */  \
# unsigned int FIRFILT(_get_length)(FIRFILT() _q);                \
#                                                                 \
# /* compute complex frequency response of filter object      */  \
# /*  _q      : filter object                                 */  \
# /*  _fc     : frequency to evaluate                         */  \
# /*  _H      : pointer to output complex frequency response  */  \
# void FIRFILT(_freqresponse)(FIRFILT()              _q,          \
#                             float                  _fc,         \
#                             liquid_float_complex * _H);         \
#                                                                 \
# /* compute and return group delay of filter object          */  \
# /*  _q      : filter object                                 */  \
# /*  _fc     : frequency to evaluate                         */  \
# float FIRFILT(_groupdelay)(FIRFILT() _q,                        \
                           # float     _fc);                      \
import Base: print, length, push!

export FIRFilter

type FIRFilter{Ty,Ti,Tx}
    yt::Type{Ty}
    it::Type{Ti}
    xt::Type{Tx}
    q::Ptr{Void}
end

Base.show(io::IO, obj::FIRFilter) = print(io::IO, "FIRFilter")

function Base.showall(io::IO, obj::FIRFilter)
    println(io::IO)
    print(obj)
end

for (sigstr, Ty, Ti, Tx) in (rrrf, crcf, cccf)

    liquid_function = "firfilt_$(sigstr)_create"

    @eval begin
        function FIRFilter(::Type{$Ty}, ::Type{$Tx}, h::Vector{$Ti} )
            q   = ccall(($liquid_function, libliquid), Ptr{Void}, (Ptr{$Ti}, Cuint), h, length(h))
            obj = FIRFilter($Ty, $Ti, $Tx, q)
            finalizer(obj, destroy)
            return obj
        end
    end


    for (jfname, lfname, rettype) in [(:destroy, :destroy, Void), (:print, :print, Void), (:reset!, :reset, Void), (:length, :length, Cint)]
        liquid_function = "firfilt_$(sigstr)_$(lfname)"
        @eval begin
            function $jfname( obj::FIRFilter{$Ty,$Ti,$Tx} )
                ccall(($liquid_function, libliquid), $rettype, (Ptr{Void},), obj.q)
            end
        end
    end

    for (jfname, lfname, rettype) in [(:execute, :execute_block, Void)]
        liquid_function = "firfilt_$(sigstr)_$(lfname)"
        @eval begin
            function $jfname( obj::FIRFilter{$Ty,$Ti,$Tx}, x::Vector{$Tx} )
                xLen = length(x)
                y = Array($Ty, xLen)
                ccall(($liquid_function, libliquid), $rettype, (Ptr{Void}, Ptr{$Tx}, Cuint, Ptr{$Ty}), obj.q, x, xLen, y)
                return y
            end
        end
    end
end

#=

reload("/Users/jay/.julia/v0.4/LiquidDSP/src/LiquidDSP.jl")
h      = sinpi(linspace(Float32(0),Float32(1),11))
myfilt = LiquidDSP.FIRFilter(Float32, Float32, h)
LiquidDSP.print(myfilt)
LiquidDSP.execute(myfilt, ones(Float32, 22))
LiquidDSP.reset!(myfilt)
LiquidDSP.destroy(myfilt)
=#
