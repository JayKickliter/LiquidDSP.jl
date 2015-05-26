import DSP
import LiquidDSP
using Base.Test

const liq = LiquidDSP
const dsp = DSP

h    = convert(Vector{Float32}, dsp.digitalfilter(dsp.Lowpass(0.5), dsp.FIRWindow(dsp.hamming(21))))
ff_d = dsp.FIRFilter(h)
ff_l = liq.FIRFilter(Float32, h)

x    = rand(Float32, 101)
y_d  = dsp.filt(ff_d, x)
y_l  = liq.execute(ff_l, x)

@test_approx_eq y_l y_d

liq.destroy(ff_l)

@test_throws ErrorException liq.execute(ff_l, x)