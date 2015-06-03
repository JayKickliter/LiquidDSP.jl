# /* create arbitrary resampler object with a specified input */  \
# /* resampling rate and default parameters                   */  \
# /*  m (filter semi-length) = 7                              */  \
# /*  fc (filter cutoff frequency) = 0.25                     */  \
# /*  As (filter stop-band attenuation) = 60 dB               */  \
# /*  npfb (number of filters in the bank) = 64               */  \
# RESAMP() RESAMP(_create_default)(float _rate);                  \
#                                                                 \
#                                                                 \
#                                                                 \
#                                                                 \
# /* get resampler delay (output samples)                     */  \
# unsigned int RESAMP(_get_delay)(RESAMP() _q);                   \
#                                                                 \
# /* set rate of arbitrary resampler                          */  \
# void RESAMP(_setrate)(RESAMP() _q, float _rate);                \
#                                                                 \
# /* execute arbitrary resampler                              */  \
# /*  _q              :   resamp object                       */  \
# /*  _x              :   single input sample                 */  \
# /*  _y              :   output sample array (pointer)       */  \
# /*  _num_written    :   number of samples written to _y     */  \
# void RESAMP(_execute)(RESAMP()       _q,                        \
#                       TI             _x,                        \
#                       TO *           _y,                        \
#                       unsigned int * _num_written);             \
#                                                                 \

import Base: print, length, push!

type Resamp{Th,Tx}
    q::Ptr{Th}
    tx::Type{Tx}
    rate::Float64
end

Base.show{Th,Tx}(io::IO, obj::Resamp{Th,Tx}) = print(io::IO, "Resamp{$Th,$Tx}")

function Base.showall(io::IO, obj::Resamp)
    println(io::IO)
    print(obj)
end

for (sigstr, Ty, Th, Tx) in (rrrf, crcf, cccf)

    # /* create arbitrary resampler object                        */  \
    # /*  _rate   : arbitrary resampling rate                     */  \
    # /*  _m      : filter semi-length (delay)                    */  \
    # /*  _fc     : filter cutoff frequency, 0 < _fc < 0.5        */  \
    # /*  _As     : filter stop-band attenuation [dB]             */  \
    # /*  _npfb   : number of filters in the bank                 */  \
    # RESAMP() RESAMP(_create)(float        _rate,                    \
    #                          unsigned int _m,                       \
    #                          float        _fc,                      \
    #                          float        _As,                      \
    #                          unsigned int _npfb);                   \

    @eval begin
        function Resamp(::Type{$Tx}, ::Type{$Th}, rate::Real, tapsPerϕ::Integer, Nϕ::Integer=32; As::Real = 60.0, fc::FloatingPoint=0.5/32)
            q   = ccall(($"resamp_$(sigstr)_create", liquiddsp), Ptr{$Th}, (Float32, Cuint, Float32, Float32, Cuint), rate, tapsPerϕ, fc, As, Nϕ)
            obj = Resamp(q, $Tx, rate)
            finalizer(obj, destroy)
            return obj
        end
    end


    # /* print resamp object internals to stdout                  */  \
    # void RESAMP(_print)(RESAMP() _q);                               \
    
    @eval begin
        function print( obj::Resamp{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"resamp_$(sigstr)_print", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* reset resamp object internals                            */  \
    # void RESAMP(_reset)(RESAMP() _q);                               \

    @eval begin
        function reset!( obj::Resamp{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"resamp_$(sigstr)_reset", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* destroy arbitrary resampler object                       */  \
    # void RESAMP(_destroy)(RESAMP() _q);                             \
    
    @eval begin
        function destroy( obj::Resamp{$Th,$Tx} )
            obj.q == C_NULL && return
            ccall(($"resamp_$(sigstr)_destroy", liquiddsp), Void, (Ptr{$Th},), obj.q)
            obj.q = C_NULL
        end
    end


    # /* execute arbitrary resampler on a block of samples        */  \
    # /*  _q              :   resamp object                       */  \
    # /*  _x              :   input buffer [size: _nx x 1]        */  \
    # /*  _nx             :   input buffer                        */  \
    # /*  _y              :   output sample array (pointer)       */  \
    # /*  _ny             :   number of samples written to _y     */  \
    # void RESAMP(_execute_block)(RESAMP()       _q,                  \
    #                             TI *           _x,                  \
    #                             unsigned int   _nx,                 \
    #                             TO *           _y,                  \
    #                             unsigned int * _ny);                \
    
    @eval begin
        function execute( obj::Resamp{$Th,$Tx}, x::Vector{$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            xLen = length(x)
            yLen = ceil(Int, 1.1 * xLen * obj.rate) + 4
            y = Array($Ty, yLen)
            samplesWritten = [zero(Cuint)]
            ccall(($"resamp_$(sigstr)_execute_block", liquiddsp), Void, (Ptr{$Th}, Ptr{$Tx}, Cuint, Ptr{$Ty}, Ptr{Cuint}), obj.q, x, xLen, y, samplesWritten)
            resize!(y, samplesWritten[1])
        end
    end
end

# If passed only taps, assume x will be the same type
function Resamp(interpolation::Integer, h::AbstractVector)
    h = limitprecision(h)
    Resamp(eltype(h), interpolation, h)
end




# /* create interpolator from prototype
# /*  _M      : interpolation factor
# /*  _m      : filter delay (symbols)
# /*  _As     : stop-band attenuation [dB]
# FIRINTERP() FIRINTERP(_create_prototype)(unsigned int _M,
#                                          unsigned int _m,
#                                          float        _As);
#
# /* create Nyquist interpolator
# /*  _type   : filter type (e.g. LIQUID_FIRFILT_RCOS)
# /*  _k      :   samples/symbol,          _k > 1
# /*  _m      :   filter delay (symbols),  _m > 0
# /*  _beta   :   excess bandwidth factor, _beta < 1
# /*  _dt     :   fractional sample delay, _dt in (-1, 1)
# FIRINTERP() FIRINTERP(_create_nyquist)(int          _type,
#                                        unsigned int _k,
#                                        unsigned int _m,
#                                        float        _beta,
#                                        float        _dt);
#
# /* create square-root Nyquist interpolator
# /*  _type   : filter type (e.g. LIQUID_FIRFILT_RRC)
# /*  _k      :   samples/symbol,          _k > 1
# /*  _m      :   filter delay (symbols),  _m > 0
# /*  _beta   :   excess bandwidth factor, _beta < 1
# /*  _dt     :   fractional sample delay, _dt in (-1, 1)
# FIRINTERP() FIRINTERP(_create_rnyquist)(int          _type,
#                                         unsigned int _k,
#                                         unsigned int _m,
#                                         float        _beta,
#                                         float        _dt);
#
#
#
#
# /* execute interpolation on single input sample
# /*  _q      : resamp object
# /*  _x      : input sample
# /*  _y      : output sample array [size: _M x 1]
# void FIRINTERP(_execute)(FIRINTERP() _q,
#                          TI          _x,
#                          TO *        _y);
