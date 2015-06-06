export gettaps

immutable Dotprod{T}
    n::Cuint  # length
    h::Ptr{T} # coefficients array
end

function gettaps{T}(obj::Ptr{Dotprod{T}})
    dp = unsafe_load(obj)
    pointer_to_array(dp.h, dp.n)
end

function gettaps{T}(obj::Dotprod{T})
    pointer_to_array(obj.h, obj.n)
end