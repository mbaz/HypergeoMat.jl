module HypergeoMat

export hypergeomPQ
export lmvgamma
export mvgamma
export BesselA

module HypergeomPQ

export hypergeomPQ
import LinearAlgebra

function DictParts(m::Integer, n::Integer)
  D = Dict{Int64,Int64}()
  Last = hcat([0, m, m])
  fin = 0
  for i = 1:n
    NewLast = Array{Int64}(undef, 3, 0)
    for record in eachcol(Last)
      @inbounds manque = record[2]
      @inbounds l = min(manque, record[3])
      if l > 0
        @inbounds D[record[1]+1] = fin + 1
        x = Array{Int64}(undef, 3, l)
        for j = 1:l
          @inbounds x[:, j] = [fin + j, manque - j, j]
        end
        NewLast = hcat(NewLast, x)
        fin += l
      end
    end
    Last = NewLast
  end
  return (D, fin)
end

function _N(dico::Dict{I,I}, lambda::Vector{I}) where {I<:Integer}
  lambda = filter(x -> x > 0, lambda)
  if isempty(lambda)
    return 1
  end
  @inbounds dico[_N(dico, lambda[1:end-1])] + last(lambda)
end

function _T(
  alpha::R,
  a::Vector{<:Union{R,Complex{R}}},
  b::Vector{<:Union{R,Complex{R}}},
  kappa::Vector{<:Integer},
) where {R<:Real}
  isComplex = eltype(a) <: Complex || eltype(b) <: Complex
  if isempty(kappa) || kappa[1] == 0
    return isComplex ? Complex(R(1)) : R(1)
  end
  i = lastindex(kappa)
  @inbounds c = kappa[i] - 1 - (i - 1) / alpha
  @inbounds d = alpha * kappa[i] - i
  @inbounds s = collect(1:(kappa[i]-1))
  e = d .- alpha .* s + map(j -> count(>=(j), kappa), s)
  g = e .+ 1
  ss = 1:(i-1)
  @inbounds f = alpha .* kappa[ss] - collect(ss) .- d
  h = f .+ alpha
  l = h .* f
  prod1 = prod(a .+ c)
  prod2 = prod(b .+ c)
  prod3 = prod((g .- alpha) .* e ./ (g .* (e .+ alpha)))
  prod4 = prod((l - f) ./ (l + h))
  out = prod1 / prod2 * prod3 * prod4
  return isinf(out) || isnan(out) ? (isComplex ? Complex(R(0)) : R(0)) : out
end

function betaratio(
  kappa::Vector{I},
  mu::Vector{I},
  k::I,
  alpha::T,
) where {I<:Integer,T<:Real}
  @inbounds muk = mu[k]
  t = k - alpha * muk
  @inbounds u = map(i -> t + 1 - i + alpha * kappa[i], 1:k)
  @inbounds v = map(i -> t - i + alpha * mu[i], 1:(k-1))
  muPrime = dualPartition(mu)
  @inbounds w = map(i -> muPrime[i] - t - alpha * i, 1:(muk-1))
  prod1 = prod(u ./ (u .+ alpha .- 1))
  prod2 = prod((v .+ alpha) ./ v)
  prod3 = prod((w .+ alpha) ./ w)
  return alpha * prod1 * prod2 * prod3
end

function dualPartition(lambda::Vector{T}) where {T<:Integer}
  out = T[]
  if !isempty(lambda)
    @inbounds for i = 1:lambda[1]
      push!(out, count(>=(i), lambda))
    end
  end
  return out
end

# ------------------------------------------------------------------------------
function hypergeomI(
  m::I,
  alpha::R,
  a::Vector{<:Union{R,Complex{R}}},
  b::Vector{<:Union{R,Complex{R}}},
  n::I,
  x::Union{R,Complex{R}},
)::Union{R,Complex{R}} where {I<:Integer,R<:Real}
  function summation(
    i::Int64,
    z::T,
    j::I,
    kappa::Vector{I},
  ) where {R<:Real,T<:Union{R,Complex{R}}}
    function go(kappai::I, zz::T, s::T) where {R<:Real,T<:Union{R,Complex{R}}}
      @inbounds if i == 0 && kappai > j || i > 0 && kappai > min(kappa[i], j)
        return s
      else
        kappap = vcat(kappa, [kappai])
        t = _T(alpha, a, b, filter(x -> x > 0, kappap))
        zp = zz * x * (n - i + alpha * (kappai - 1)) * t
        sp = j > kappai && i <= n ? s + summation(i + 1, zp, j - kappai, kappap) : s
        spp = sp + zp
        go(kappai + 1, zp, spp)
      end
    end # end go ---------------------------------------------------------------
    go(I(1), z, T(0))
  end # end summation ----------------------------------------------------------
  isComplex = eltype(a) <: Complex || eltype(b) <: Complex || eltype(x) <: Complex
  the_one = isComplex ? Complex(R(1)) : R(1)
  return the_one + summation(0, the_one, m, I[])
end

# ------------------------------------------------------------------------------
"""
    hypergeomPQ(m, a, b, x[, alpha])

Compute the truncated hypergeometric function of a matrix argument given the 
  eigen values of the matrix.

# Arguments
- `m`: truncation weight of the summation, a positive integer
- `a`: the "upper" parameters, a real or complex vector, possibly empty
- `b`: the "lower" parameters, a real or complex vector, possibly empty
- `x`: real or complex vector, the eigen values
- `alpha`: the alpha parameter, a positive number; if missing, `alpha=2` is used
"""
function hypergeomPQ(
  m::Integer,
  a::Vector{<:Union{R,T}},
  b::Vector{<:Union{R,T}},
  x::Vector{<:Union{R,T}},
  alpha::Union{Nothing,R} = nothing,
) where {R<:Real,T<:Complex{R}}
  if isnothing(alpha)
    alpha = R(2)
  end
  n = length(x)
  @inbounds if all(x .== x[1])
    @inbounds return hypergeomI(m, alpha, a, b, n, x[1])
  end
  function jack(
    k::I,
    beta::Union{R,Complex{R}},
    c::I,
    t::Integer,
    mu::Vector{I},
    jarray::Array{<:Union{R,Complex{R}},2},
    kappa::Vector{I},
    nkappa::I,
  ) where {I<:Integer}
    lmu = length(mu)
    for i in ((max(k, 1):count(>(0), mu)))
      @inbounds u = mu[i]
      @inbounds if lmu == i || u > mu[i+1]
        gamma = beta * betaratio(kappa, mu, i, alpha)
        mup = copy(mu)
        @inbounds mup[i] = u - 1
        filter!(>(0), mup)
        if length(mup) >= i && u > 1
          jarray = jack(i, gamma, c + 1, t, mup, jarray, kappa, nkappa)
        else
          if nkappa > 1
            if !isempty(mup)
              @inbounds jarray[nkappa, t] +=
                gamma * jarray[_N(dico, mup)-1, t-1] * x[t]^(c + 1)
            else
              @inbounds jarray[nkappa, t] += gamma * x[t]^(c + 1)
            end
          end
        end
      end
    end
    if k == 0
      if nkappa > 1
        @inbounds jarray[nkappa, t] += jarray[nkappa, t-1]
      end
    else
      @inbounds jarray[nkappa, t] += beta * x[t]^c * jarray[_N(dico, mu)-1, t-1]
    end
    return jarray
  end # end jack ---------------------------------------------------------------
  function summation(
    i::I,
    z::T,
    j::I,
    kappa::Vector{I},
    jarray::Array{T,2},
  ) where {I<:Integer,R<:Real,T<:Union{R,Complex{R}}}
    function go(kappai::I, zp::T, s::T)
      if i == n || i == 0 && kappai > j || i > 0 && kappai > min(last(kappa), j)
        return s
      end
      kappap = vcat(kappa, [kappai])
      nkappa = _N(dico, kappap) - 1
      zpp = zp * _T(alpha, a, b, kappap)
      @inbounds if nkappa > 1 && (length(kappap) == 1 || kappap[2] == 0)
        @inbounds jarray[nkappa, 1] =
          x[1] * (1 + alpha * (kappap[1] - 1)) * jarray[nkappa-1, 1]
      end
      for t = 2:n
        jarray = jack(I(0), T(1), I(0), t, kappap, jarray, kappap, nkappa)
      end
      @inbounds sp = s + zpp * jarray[nkappa, n]
      if j > kappai && i <= n
        spp = summation(i + 1, zpp, j - kappai, kappap, jarray)
        go(kappai + 1, zpp, sp + spp)
      else
        go(kappai + 1, zpp, sp)
      end
    end # end go ---------------------------------------------------------------
    go(I(1), T(z), T(0))
  end # end summation ----------------------------------------------------------
  the_one =
    eltype(a) <: Complex || eltype(b) <: Complex || eltype(x) <: Complex ? Complex(R(1)) :
    R(1)
  (dico, Pmn) = DictParts(m, n)
  J = zeros(typeof(the_one), Pmn, n)
  @inbounds J[1, :] = cumsum(x)
  return the_one + summation(0, the_one, m, Int64[], J)
end

# univariate -------------------------------------------------------------------
"""
    hypergeomPQ(m, a, b, x)

Compute the truncated hypergeometric function of a scalar argument.

# Arguments
- `m`: truncation weight of the summation, a positive integer
- `a`: the "upper" parameters, a real or complex vector, possibly empty
- `b`: the "lower" parameters, a real or complex vector, possibly empty
- `x`: scalar, real or complex
"""
function hypergeomPQ(
  m::Integer,
  a::Vector{<:Union{R,T}},
  b::Vector{<:Union{R,T}},
  x::Union{R,T},
) where {R<:Real,T<:Complex{R}}
  return hypergeomI(m, R(2), a, b, 1, x)
end

# matrix argument --------------------------------------------------------------
"""
    hypergeomPQ(m, a, b, X[, alpha])

Compute the truncated hypergeometric function of a matrix argument. The 
  hypergeometric function is usually defined for a symmetric real matrix  
  or a Hermitian complex matrix but arbitrary square matrices are allowed.

# Arguments
- `m`: truncation weight of the summation, a positive integer
- `a`: the "upper" parameters, a real or complex vector, possibly empty
- `b`: the "lower" parameters, a real or complex vector, possibly empty
- `X`: a square matrix, real or complex
- `alpha`: the alpha parameter, a positive number; if missing, `alpha=2` is used
"""
function hypergeomPQ(
  m::Integer,
  a::Vector{<:Union{R,T}},
  b::Vector{<:Union{R,T}},
  X::Matrix{<:Union{R,T}},
  alpha::Union{Nothing,R} = nothing,
) where {R<:Real,T<:Complex{R}}
  x = LinearAlgebra.eigvals(X)
  return hypergeomPQ(m, a, b, x, alpha)
end

end # end module HypergeomPQ

module Mvgamma

export lmvgamma
export mvgamma
import GSL

"""
    lmvgamma(z, p)

Compute the logarithm of the multivariate Gamma function.

# Arguments
- `z`: real or complex number
- `p`: positive integer, the dimension
"""
function lmvgamma(
  z::Union{R,T},
  p::Integer
) where {R<:Real,T<:Complex{R}}
  if real(z) <= 0
    throw(DomainError(z, "The real part of `z` is not positive."))
  end
  C = p*(p-1)/4.0 * log(pi)
  isComplex = eltype(z) <: Complex
  if isComplex
    z_re = real(z)
    z_im = imag(z)
    (a, b) = GSL.sf_lngamma_complex_e(z_re, z_im)
    S = complex(a.val, b.val)
    for i in 2:p
      (a, b) = GSL.sf_lngamma_complex_e(z_re + (1 - i)/2.0, z_im)
      S = S + complex(a.val, b.val)
    end
  else
    S = GSL.sf_lngamma(z)
    for i in 2:p
      S = S + GSL.sf_lngamma(z + (1 - i)/2.0)
    end
  end
  return C + S
end

"""
    mvgamma(z, p)

Compute the multivariate Gamma function.

# Arguments
- `z`: real or complex number
- `p`: positive integer, the dimension
"""
function mvgamma(
  z::Union{R,T},
  p::Integer
) where {R<:Real,T<:Complex{R}}
  if imag(z) == 0 && real(z) <= 0 && trunc(z) == z
    throw(DomainError(z, "The argument `z` is a non-positive integer."))
  end
  if real(z) > 0.0
    result = exp(lmvgamma(z, p))
  else
    n = 1 + floor(-real(z))
    pochhammer = z
    for i in 2:n
      pochhammer = pochhammer * (z + i - 1.0)
    end
    result = exp(lmvgamma(z + n, p)) / pochhammer
  end
  return result
end

end # end module Mvgamma

module Bessel

export BesselA

"""
    BesselA(m, X, nu)

Compute the truncated Herz's type one Bessel function of a matrix argument. It  
  is usually defined for a symmetric real matrix or a Hermitian complex matrix 
  but arbitrary square matrices are allowed.

# Arguments
- `m`: truncation weight of the hypergeometric function, a positive integer
- `X`: a square matrix, real or complex
- `nu`: the order parameter, real or complex number with `real(nu)>-1`
"""
function BesselA(
  m::Integer,
  X::Matrix{<:Union{R,T}},
  nu::Union{R,T}
) where {R<:Real,T<:Complex{R}}
  if real(nu) <= -1
    throw(DomainError(nu, "The real part of `nu` is smaller than -1."))
  end
  p = size(X)[1]
  b = nu + (p+1) / 2.0
  return hypergeomPQ(m, Float64[], [b], -X, 2.0) / mvgamma(b, p)
end

"""
    BesselA(m, x, nu)

Compute the truncated Herz's type one Bessel function of a matrix argument 
  given the eigen values of the matrix. 

# Arguments
- `m`: truncation weight of the hypergeometric function, a positive integer
- `x`: the eigen values, a vector of real or complex numbers
- `nu`: the order parameter, real or complex number with `real(nu)>-1`
"""
function BesselA(
  m::Integer,
  x::Vector{<:Union{R,T}},
  nu::Union{R,T}
) where {R<:Real,T<:Complex{R}}
  if real(nu) <= -1
    throw(DomainError(nu, "The real part of `nu` is smaller than -1."))
  end
  p = length(x)
  b = nu + (p+1) / 2.0
  return hypergeomPQ(m, Float64[], [b], -x, 2.0) / mvgamma(b, p)
end

using ..HypergeomPQ
using ..Mvgamma

end # end module Bessel

using .HypergeomPQ
using .Mvgamma

end