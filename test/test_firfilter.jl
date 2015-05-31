using LiquidDSP
using Base.Test
import DSP

const dsp = DSP

for (Th, Tx) in [(Float32, Float32), (Float32, Complex64), (Complex64, Complex64)]
    h    = dsp.digitalfilter(dsp.Lowpass(0.5), dsp.FIRWindow(dsp.hamming(21)))
    h    = convert(Vector{Th}, h)
    x    = rand(Tx, 101)
    ff_d = dsp.FIRFilter(h)
    ff_l = FIRFilter(Tx, h)

    # Test gettaps 
    h_l = gettaps(ff_l)
    @test_approx_eq h_l h

    y_d  = dsp.filt(ff_d, x)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d

    ff_l = FIRFilter(Tx, h)
    y_l  = execute(ff_l, x)
    @test_approx_eq y_l y_d

    ff_l = FIRFilter(Tx, h)
    for i in 1:length(x)
        push!(ff_l, x[i])
        y_l[i] = execute(ff_l)
    end
    @test_approx_eq y_l y_d

    z_d = dsp.freqz(dsp.PolynomialRatio(h,[1]), linspace(0,pi,100))
    z_l = [freqresponse(ff_l, f) for f in linspace(0,0.5,100)]
    @test_approx_eq abs(z_d) abs(z_l)

    @test_throws ArgumentError  freqresponse(ff_l, 0.0-eps(0.0))
    @test_throws ArgumentError  freqresponse(ff_l, 0.5+eps(0.5))
    @test_throws ArgumentError  groupdelay(ff_l, 0.0-eps(0.0))
    @test_throws ArgumentError  groupdelay(ff_l, 0.5+eps(0.5))

    destroy(ff_l)
    @test_throws ErrorException execute(ff_l, x)
end

