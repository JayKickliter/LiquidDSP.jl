using LiquidDSP
using Base.Test
import DSP

for (Th, Tx) in [(Float32, Float32), (Float32, Complex64), (Complex64, Complex64)]
    # Create taps and filters
    h    = DSP.digitalfilter(DSP.Lowpass(0.5), DSP.FIRWindow(DSP.hamming(21)))
    h    = convert(Vector{Th}, h)
    x    = rand(Tx, 100)
    ff_d = DSP.FIRFilter(h, 1//2)
    ff_l = FIRDecim(Tx, 2, h)

    # Test filtering
    y_d  = DSP.filt(ff_d, x)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d
    
    # Test reset
    reset!(ff_l)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d
    
    # Test destroy
    destroy(ff_l)
    @test_throws ErrorException execute(ff_l, x)
end
