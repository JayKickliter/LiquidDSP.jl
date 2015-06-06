immutable FIRPFB{Th,Tx}
    h::Ptr{Th}                  # filter coefficients array
    h_len::Cint                 # total number of filter coefficients
    h_sub_len::Cint             # sub-sampled filter length
    num_filters::Cint           # number of filters

    w::Ptr{Window{Tx}}          # window buffer
    dp::Ptr{Ptr{Dotprod{Tx}}}   # array of vector dot product objects
    scale::Th                   # output scaling factor
end

function gettaps(obj::FIRPFB)
    pointer_to_array(obj.h, obj.h_len)
end

function gettaps{Th,Tx}(obj::Ptr{FIRPFB{Th,Tx}})
    obj = unsafe_load(obj)
    gettaps(obj)
end