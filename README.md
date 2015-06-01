[![Build Status](https://travis-ci.org/JayKickliter/LiquidDSP.jl.svg?branch=master)](https://travis-ci.org/JayKickliter/LiquidDSP.jl)

# LiquidDSP

This Julia package is a wrapper for Joseph Gaeddert's excellent digital communications library, [liquid-dsp](http://liquidsdr.org).

## Usage

This package follows **liquid-dsp**'s calling conventions fairly closely, with a few exceptions. The biggest difference is the use of [CamelCase](http://en.wikipedia.org/wiki/CamelCase) for object names, and the lack of type signatures in function names.

### `liquid-dsp` c code

```c
// Create firdecim object with:
//      a decimation factor of 2
//      an already defined vector of taps named h
//      of length h_len

firdecim_rrrf myfilt = firdecim_rrrf_create(2, h, h_len);

// Execute filter on an array of float samples
//      myfilt is the firdecim object created above
//      x is holds the output samples
//      n_out is the number of output samples
//      y is the buffer to write the output samples to

firdecim_rrrf_execute_block(myfilt, x, n_out, y);
```

### `LiquidDSP.jl` Equivalent Julia code

```Julia
# Create firdecim object with:
#      a decimation factor of 2
#      an already defined vector of taps named h
#      an input type of Float32

myfilt = LiquidDSP.FIRDecim(Float32, 2, h)

# Execute myfilt on a vector of input samples named x

y = execute(myfilt, x)

```
