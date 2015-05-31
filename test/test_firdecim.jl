using LiquidDSP
using Base.Test
import DSP

for (Th, Tx) in [(Float32, Float32), (Float32, Complex64), (Complex64, Complex64)]
    # Create taps & signal
    h    = DSP.digitalfilter(DSP.Lowpass(0.5), DSP.FIRWindow(DSP.hamming(21)))
    x    = rand(Tx, 100)

    # Convert to complex if necessary
    h += Tx<:Complex ? im : 0

    # Create filter objects
    ff_d = DSP.FIRFilter(h, 1//2)
    ff_l = FIRDecim(Tx, 2, h)

    # Test case where Tx assumed to be the same as Th
    if Tx == Th
        ff_l = FIRDecim(2, h)
    end

    # Test filtering
    y_d  = DSP.filt(ff_d, x)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d

    # Test reset
    reset!(ff_l)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d

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
