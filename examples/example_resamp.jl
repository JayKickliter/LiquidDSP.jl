using LiquidDSP

# Construct signal vector
tx  = linspace(Float32(0), Float32(1), 20)
x   = sinpi(2tx)

# Construct Resamp object
obj = Resamp(Float32, Float32, 3.1415926535897)
delay = getdelay(obj)
h = gettaps(obj)

# Resample x
y   = execute(obj, x)


#=
pfb = unsafe_load(obj.f)
gettaps(pfb)
dpa = pointer_to_array(pfb.dp, pfb.num_filters)
dps = [unsafe_load(dpp) for dpp in dpa]
pointer_to_array(dps[2].h, dps[2].n)
h   = gettaps(dpp)
=#


# # Plot x & y
# using PyPlot
# ty = linspace(0, 1, length(y))
#
# plot(tx, x, ".-")
# hold(true)
# plot(ty, y, ".-")
# hold(false)