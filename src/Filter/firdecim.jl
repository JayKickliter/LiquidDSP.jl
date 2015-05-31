
import Base: print, length, push!

type FIRDecim{Th,Tx}
    q::Ptr{Th}
    tx::Type{Tx}
    decimation::Int
end

Base.show{Th,Tx}(io::IO, obj::FIRDecim{Th,Tx}) = print(io::IO, "FIRDecim{$Th,$Tx}")

function Base.showall(io::IO, obj::FIRDecim)
    println(io::IO)
    print(obj)
end

for (sigstr, Ty, Th, Tx) in (rrrf, crcf, cccf)

    # /* create decimator from external coefficients              */  \
    # /*  _M      : decimation factor                             */  \
    # /*  _h      : filter coefficients [size: _h_len x 1]        */  \
    # /*  _h_len  : filter coefficients length                    */  \
    # FIRDECIM() FIRDECIM(_create)(unsigned int _M,                   \
    #                              TC *         _h,                   \
    #                              unsigned int _h_len);              \

    @eval begin
        function FIRDecim(::Type{$Tx}, decimation::Integer, h::Vector{$Th})
            q   = ccall(($"firdecim_$(sigstr)_create", liquiddsp), Ptr{$Th}, (Cuint, Ptr{$Th}, Cuint), decimation, h, length(h))
            obj = FIRDecim(q, $Tx, decimation)
            finalizer(obj, destroy)
            return obj
        end
    end


    # /* create decimator from prototype
    # /*  _M      : decimation factor
    # /*  _m      : filter delay (symbols)
    # /*  _As     : stop-band attenuation [dB]
    # FIRDECIM() FIRDECIM(_create_prototype)(unsigned int _M,
    #                                        unsigned int _m,
    #                                        float        _As);

    # TODO: this function doesn't appear to be working on the liquid-dsp side of th house
    # @eval begin
    #     function FIRDecim(::Type{$Tx}, decimation::Integer, attenuation::Real, delay::Integer = 11)
    #         delay > 0 || throw(ArgumentError("Delay, (hLen-1)/(2*decimation), must be greater than 0"))
    #         q   = ccall(($"firdecim_$(sigstr)_create_prototype", liquiddsp), Ptr{$Th}, (Cuint, Cuint, Float32), decimation, delay, attenuation)
    #         obj = FIRDecim(q, $Tx, decimation)
    #         finalizer(obj, destroy)
    #         return obj
    #     end
    # end


    # /* print decimator object propreties to stdout              */  \
    # void FIRDECIM(_print)(FIRDECIM() _q);                           \

    @eval begin
        function print( obj::FIRDecim{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firdecim_$(sigstr)_print", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* reset decimator object internal state                    */  \
    # void FIRDECIM(_clear)(FIRDECIM() _q);                           \

    @eval begin
        function reset!( obj::FIRDecim{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firdecim_$(sigstr)_clear", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* destroy decimator object                                 */  \
    # void FIRDECIM(_destroy)(FIRDECIM() _q);                         \

    @eval begin
        function destroy( obj::FIRDecim{$Th,$Tx} )
            obj.q == C_NULL && return
            ccall(($"firdecim_$(sigstr)_destroy", liquiddsp), Void, (Ptr{$Th},), obj.q)
            obj.q = C_NULL
        end
    end


    # /* execute decimator on block of _n*_M input samples        */  \
    # /*  _q      : decimator object                              */  \
    # /*  _x      : input array [size: _n*_M x 1]                 */  \
    # /*  _n      : number of _output_ samples                    */  \
    # /*  _y      : output array [_size: _n x 1]                  */  \
    # void FIRDECIM(_execute_block)(FIRDECIM()   _q,                  \
    #                               TI *         _x,                  \
    #                               unsigned int _n,                  \
    #                               TO *         _y);                 \

    @eval begin
        function execute( obj::FIRDecim{$Th,$Tx}, x::Vector{$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            xLen = length(x)
            xLen % obj.decimation == 0 || error("input must be an integer multiple of the decimation factor")
            yLen = div(xLen, obj.decimation)
            y = Array($Ty, yLen)
            ccall(($"firdecim_$(sigstr)_execute_block", liquiddsp), Void, (Ptr{$Th}, Ptr{$Tx}, Cuint, Ptr{$Ty}), obj.q, x, yLen, y)
            return y
        end
    end
end

# Handle conversion of taps tp Float32
FIRDecim(Tx::Type, decimation::Integer, h::AbstractVector) = FIRDecim(Tx, decimation, limitprecision(h))

# If passed only taps, assume x will be the same type
function FIRDecim(decimation::Integer, h::AbstractVector)
    h = limitprecision(h)
    FIRDecim(eltype(h), decimation, h)
end


#################################################################
# _ _  _ ___  _    ____ _  _ ____ _  _ ___ ____ ___ _ ____ _  _ #
# | |\/| |__] |    |___ |\/| |___ |\ |  |  |__|  |  | |  | |\ | #
# | |  | |    |___ |___ |  | |___ | \|  |  |  |  |  | |__| | \| #
#                                                               #
#             ___  ____ _  _ ___  _ _  _ ____                   #
#             |__] |___ |\ | |  \ | |\ | | __                   #
#             |    |___ | \| |__/ | | \| |__]                   #
#################################################################

#
# /* create decimator from prototype
# /*  _M      : decimation factor
# /*  _m      : filter delay (symbols)
# /*  _As     : stop-band attenuation [dB]
# FIRDECIM() FIRDECIM(_create_prototype)(unsigned int _M,
#                                        unsigned int _m,
#                                        float        _As);
#
# /* create square-root Nyquist decimator
# /*  _type   : filter type (e.g. LIQUID_FIRFILT_RRC)
# /*  _M      : samples/symbol (decimation factor)
# /*  _m      : filter delay (symbols)
# /*  _beta   : rolloff factor (0 < beta <= 1)
# /*  _dt     : fractional sample delay
# FIRDECIM() FIRDECIM(_create_rnyquist)(int          _type,
#                                       unsigned int _M,
#                                       unsigned int _m,
#                                       float        _beta,
#                                       float        _dt);
#
#
#
# /* execute decimator on _M input samples
# /*  _q      : decimator object
# /*  _x      : input samples [size: _M x 1]
# /*  _y      : output sample pointer
# void FIRDECIM(_execute)(FIRDECIM() _q,
#                         TI *       _x,
#                         TO *       _y);
#
