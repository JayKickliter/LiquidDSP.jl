import Base: print, length, push!

type FIRFilter{Th,Tx}
    q::Ptr{Th}
    tx::Type{Tx}
end

Base.show(io::IO, obj::FIRFilter) = print(io::IO, "FIRFilter")

function Base.showall(io::IO, obj::FIRFilter)
    println(io::IO)
    print(obj)
end

for (sigstr, Ty, Th, Tx) in (rrrf, crcf, cccf)

    # FIRFILT() FIRFILT(_create)(TC * _h, unsigned int _n);

    @eval begin
        function FIRFilter(::Type{$Tx}, h::Vector{$Th} )
            q   = ccall(($"firfilt_$(sigstr)_create", liquiddsp), Ptr{$Th}, (Ptr{$Th}, Cuint), h, length(h))
            obj = FIRFilter(q,$Tx)
            finalizer(obj, destroy)
            return obj
        end
    end


    # /* print filter object information
    # void FIRFILT(_print)(FIRFILT() _q);

    @eval begin
        function print( obj::FIRFilter{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firfilt_$(sigstr)_print", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* reset filter object's internal buffer
    # void FIRFILT(_reset)(FIRFILT() _q);

    @eval begin
        function reset!( obj::FIRFilter{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firfilt_$(sigstr)_reset", liquiddsp), Void, (Ptr{$Th},), obj.q)
        end
    end


    # /* return length of filter object
    # unsigned int FIRFILT(_get_length)(FIRFILT() _q);

    @eval begin
        function length( obj::FIRFilter{$Th,$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            ccall(($"firfilt_$(sigstr)_length", liquiddsp), Cint, (Ptr{$Th},), obj.q)
        end
    end


    # /* destroy filter object and free all internal memory
    # void FIRFILT(_destroy)(FIRFILT() _q);

    @eval begin
        function destroy( obj::FIRFilter{$Th,$Tx} )
            obj.q == C_NULL && return
            ccall(($"firfilt_$(sigstr)_destroy", liquiddsp), Void, (Ptr{$Th},), obj.q)
            obj.q = C_NULL
        end
    end


    # /* execute the filter on a block of input samples; the
    # /* input and output buffers may be the same
    # /*  _q      : filter object
    # /*  _x      : pointer to input array [size: _n x 1]
    # /*  _n      : number of input, output samples
    # /*  _y      : pointer to output array [size: _n x 1]
    # void FIRFILT(_execute_block)(FIRFILT()    _q,
    #                              TI *         _x,
    #                              unsigned int _n,
    #                              TO *         _y);

    @eval begin
        function execute( obj::FIRFilter{$Th,$Tx}, x::Vector{$Tx} )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            xLen = length(x)
            y = Array($Ty, xLen)
            ccall(($"firfilt_$(sigstr)_execute_block", liquiddsp), Void, (Ptr{$Th}, Ptr{$Tx}, Cuint, Ptr{$Ty}), obj.q, x, xLen, y)
            return y
        end
    end


    # /* execute the filter on internal buffer and coefficients
    # /*  _q      : filter object
    # /*  _y      : pointer to single output sample
    # void FIRFILT(_execute)(FIRFILT() _q,
    #                        TO *      _y);

    @eval begin
        function execute( obj::FIRFilter{$Th,$Tx})
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            y = Array($Ty ,1)
            ccall(($"firfilt_$(sigstr)_execute", liquiddsp), Void, (Ptr{$Th}, Ptr{$Ty}), obj.q, y)
            return y[1]
        end
    end


    # /* push sample into filter object's internal buffer
    # /*  _q      : filter object
    # /*  _x      : single input sample
    # void FIRFILT(_push)(FIRFILT() _q,
    #                     TI        _x);

    if Tx<:Complex && VERSION.minor < 4
        @eval begin
            function push!( obj::FIRFilter{$Th,$Tx}, x::$Tx )
                obj.q == C_NULL && error("`obj` is a NULL pointer")
                ccall(($"firfilt_$(sigstr)_push", liquiddsp), Void, (Ptr{$Th}, ($realtype($Tx), $realtype($Tx))), obj.q, (real(x), imag(x)))
            end
        end
    else
        @eval begin
            function push!( obj::FIRFilter{$Th,$Tx}, x::$Tx )
                obj.q == C_NULL && error("`obj` is a NULL pointer")
                ccall(($"firfilt_$(sigstr)_push", liquiddsp), Void, (Ptr{$Th}, $Tx), obj.q, x)
            end
        end
    end


    # /* compute complex frequency response of filter object
    # /*  _q      : filter object
    # /*  _fc     : frequency to evaluate
    # /*  _H      : pointer to output complex frequency response
    # void FIRFILT(_freqresponse)(FIRFILT()              _q,
    #                             float                  _fc,
    #                             liquid_float_complex * _H);

    @eval begin
        function freqresponse( obj::FIRFilter{$Th,$Tx}, f::Real )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            0 <= f <= 0.5 || throw(ArgumentError("f must be normalized 0.5 == nyquist"))
            z = Array(Complex64, 1)
            ccall(($"firfilt_$(sigstr)_freqresponse", liquiddsp), Float32, (Ptr{$Th}, Float32, Ptr{Complex64}), obj.q, f, z)
            return z[1]
        end
    end


    # /* compute and return group delay of filter object
    # /*  _q      : filter object
    # /*  _fc     : frequency to evaluate
    # float FIRFILT(_groupdelay)(FIRFILT() _q,
    #                            float     _fc);

    @eval begin
        function groupdelay( obj::FIRFilter{$Th,$Tx}, f::Real )
            obj.q == C_NULL && error("`obj` is a NULL pointer")
            0 <= f <= 0.5 || throw(ArgumentError("f must be normalized 0.5 == nyquist"))
            ccall(($"firfilt_$(sigstr)_groupdelay", liquiddsp), Float32, (Ptr{$Th}, Float32), obj.q, f)
        end
    end
end

# Handle conversion of taps tp Float32
FIRFilter(Tx::Type, h::AbstractVector) = FIRFilter(Tx, limitprecision(h))

# If passed only taps, assume x will be the same type
function FIRFilter(h::AbstractVector)
    h = limitprecision(h)
    FIRFilter(eltype(h), h)
end

function gettaps{Th,Tx}(obj::FIRFilter{Th,Tx})
    hLenPtr = convert(Ptr{Cuint}, obj.q+sizeof(obj.q))
    hLen    = unsafe_load(hLenPtr)
    hPtr    = convert(Ptr{Ptr{Th}}, obj.q)
    h       = pointer_to_array(unsafe_load(hPtr), hLen)
end


# /* create using Kaiser-Bessel windowed sinc method
# /*  _n      : filter length, _n > 0
# /*  _fc     : filter cut-off frequency 0 < _fc < 0.5
# /*  _As     : filter stop-band attenuation [dB], _As > 0
# /*  _mu     : fractional sample offset, -0.5 < _mu < 0.5
# FIRFILT() FIRFILT(_create_kaiser)(unsigned int _n,
#                                   float        _fc,
#                                   float        _As,
#                                   float        _mu);
#
# /* create from square-root Nyquist prototype
# /*  _type   : filter type (e.g. LIQUID_FIRFILT_RRC)
# /*  _k      : nominal samples/symbol, _k > 1
# /*  _m      : filter delay [symbols], _m > 0
# /*  _beta   : rolloff factor, 0 < beta <= 1
# /*  _mu     : fractional sample offset,-0.5 < _mu < 0.5
# FIRFILT() FIRFILT(_create_rnyquist)(int          _type,
#                                     unsigned int _k,
#                                     unsigned int _m,
#                                     float        _beta,
#                                     float        _mu);
#
# /* re-create filter
# /*  _q      : original filter object
# /*  _h      : pointer to filter coefficients [size: _n x 1]
# /*  _n      : filter length, _n > 0
# FIRFILT() FIRFILT(_recreate)(FIRFILT()    _q,
#                              TC *         _h,
#                              unsigned int _n);
#
#
#
#
# /* set output scaling for filter
# void FIRFILT(_set_scale)(FIRFILT() _q,
#                          TC        _scale);
#
