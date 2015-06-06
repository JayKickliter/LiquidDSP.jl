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
    rate = 3.1415926535897
    ff_l = Resamp(Tx, Th, rate, 7, 64, As=60, fc=0.25)
    h = gettaps(ff_l)
    ff_d = DSP.FIRFilter(h, rate, 64),
    
    # Test filtering
    y_d  = DSP.filt(ff_d, x)
    y_l1  = execute(ff_l, x)
    display([y_l1 y_d y_l1.-y_d])

    @test_approx_eq y_l1 y_d

    # Test reset
    reset!(ff_l)
    y_l2  = execute(ff_l, x)
    @test_approx_eq y_l1 y_l2

    # Test destroy
    # destroy(ff_l)
    # @test_throws ErrorException execute(ff_l, x)
end
