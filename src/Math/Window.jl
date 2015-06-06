immutable Window{T}
    v::Ptr{T}               # allocated array pointer
    len::Cint              # length of window
    m::Cint                # floor(log2(len)) + 1
    n::Cint                # 2^m
    mask::Cint             # n-1
    num_allocated::Cint    # number of elements allocated in memory
    read_index::Cint
end