
import Base: print, length, push!

type FIRInterp{Th,Tx}
    q::Ptr{Th}
    tx::Type{Tx}
    interpolation::Int
end

Base.show{Th,Tx}(io::IO, obj::FIRInterp{Th,Tx}) = print(io::IO, "FIRInterp{$Th,$Tx}")

function Base.showall(io::IO, obj::FIRInterp)
    println(io::IO)
    print(obj)
end

for (sigstr, Ty, Th, Tx) in (rrrf, crcf, cccf)

    # /* create interpolator from external coefficients
    # /*  _M      : interpolation factor
    # /*  _h      : filter coefficients [size: _h_len x 1]
    # /*  _h_len  : filter length
    # FIRINTERP() FIRINTERP(_create)(unsigned int _M,
    #                                TC *         _h,
    #                                unsigned int _h_len);

    @eval begin
        function FIRInterp(::Type{$Tx}, interpolation::Integer, h::Vector{$Th})
            q   = ccall(($"firinterp_$(sigstr)_create", liquiddsp), Ptr{$Th}, (Cuint, Ptr{$Th}, Cuint), interpolation, h, length(h))
            obj = FIRInterp(q, $Tx, interpolation)
            finalizer(obj, destroy)
            return obj
        end
    end


    # /* print firinterp object's internal properties to stdout
    # void FIRINTERP(_print)(FIRINTERP() _q);
    
    @eval begin
        function print( obj::FIRInterp{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firinterp_$(sigstr)_print", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* reset internal state
    # void FIRINTERP(_reset)(FIRINTERP() _q);

    @eval begin
        function reset!( obj::FIRInterp{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firinterp_$(sigstr)_reset", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* destroy firinterp object, freeing all internal memory
    # void FIRINTERP(_destroy)(FIRINTERP() _q);
    
    @eval begin
        function destroy( obj::FIRInterp{$Th,$Tx} )
            obj.q == C_NULL && return
            ccall(($"firinterp_$(sigstr)_destroy", liquiddsp), Void, (Ptr{$Th},), obj.q)
            obj.q = C_NULL
        end
    end


    # /* execute interpolation on block of input samples
    # /*  _q      : firinterp object
    # /*  _x      : input array [size: _n x 1]
    # /*  _n      : size of input array
    # /*  _y      : output sample array [size: _M*_n x 1]
    # void FIRINTERP(_execute_block)(FIRINTERP()  _q,
    #                                TI *         _x,
    #                                unsigned int _n,
    #                                TO *         _y);
    
    @eval begin
        function execute( obj::FIRInterp{$Th,$Tx}, x::Vector{$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            xLen = length(x)
            y = Array($Ty, xLen*2)
            ccall(($"firinterp_$(sigstr)_execute_block", liquiddsp), Void, (Ptr{$Th}, Ptr{$Tx}, Cuint, Ptr{$Ty}), obj.q, x, xLen, y)
            return y
        end
    end
end

# Handle conversion of taps tp Float32
FIRInterp(Tx::Type, interpolation::Integer, h::AbstractVector) = FIRInterp(Tx, interpolation, limitprecision(h))

# If passed only taps, assume x will be the same type
function FIRInterp(interpolation::Integer, h::AbstractVector)
    h = limitprecision(h)
    FIRInterp(eltype(h), interpolation, h)
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
# /*  _q      : firinterp object
# /*  _x      : input sample
# /*  _y      : output sample array [size: _M x 1]
# void FIRINTERP(_execute)(FIRINTERP() _q,
#                          TI          _x,
#                          TO *        _y);
