using LiquidDSP
using Base.Test
import DSP

const dsp = DSP

# (Th, Tx) = (Float32, Float32)
for (Th, Tx) in [(Float32, Float32), (Float32, Complex64), (Complex64, Complex64)]
    h    = dsp.digitalfilter(dsp.Lowpass(0.5), dsp.FIRWindow(dsp.hamming(21)))
    h    = convert(Vector{Th}, h)
    x    = rand(Tx, 101)
    ff_d = dsp.FIRFilter(h, 2//1)
    ff_l = FIRInterp(Tx, 2, h)

    y_d  = dsp.filt(ff_d, x)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d
end
