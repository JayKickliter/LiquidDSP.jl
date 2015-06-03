using Winston
using LiquidDSP
using Base.Test
import DSP

fignum = 0
for (Th, Tx) in [(Float32, Float32), (Float32, Complex64), (Complex64, Complex64)]
    fignum += 1
    t = linspace(Float32(0), Float32(1), 100)
    x = sinpi(2*t)
    x += Tx<:Complex ? 0im : 0
    
    
    # Create filter objects
    # Resamp(::Type{$Tx}, ::Type{$Th}, rate::Real, tapsPerϕ::Integer, Nϕ::Integer=32; As::FloatingPoint = 60.0, fc::FloatingPoint=0.5/32)
    # ff_d = DSP.FIRFilter(h, 1//2)
    ff_l = Resamp(Tx, Th, 3.1415926535897, 7, 64, As=60, fc=0.25)
    
    # # Test case where Tx assumed to be the same as Th
    # if Tx == Th
    #     ff_l = FIRDecim(2, h)
    # end

    # Test filtering
    # y_d  = DSP.filt(ff_d, x)
    y_l1  = execute(ff_l, x)
    ty_l1 = linspace(0,1,length(y_l1))
    
    # figure(fignum)
    hold(true)
    plot(t, x)
    plot(ty_l1, y_l1)
    hold(false)
    

    # @test_approx_eq y_l y_d

    # Test reset
    reset!(ff_l)
    y_l2  = execute(ff_l, x)
    @test_approx_eq y_l1 y_l2

    # TODO: This doesn't appear to work, not testing for now
    # # Make sure create with automatic taps doesn't throw an error
    # delay = 11
    # atten = 60
    # ff_l  = FIRDecim(Tx, 2, atten, delay)
    # # Check for execption when delay is 0
    # @test_throws ArgumentError FIRDecim(Tx, 2, 60, 0)

    # Make sure print doesn't throw an error
    print(ff_l)

    # Test destroy
    destroy(ff_l)
    @test_throws ErrorException execute(ff_l, x)
end
