var documenterSearchIndex = {"docs":
[{"location":"#HypergeoMat.jl-Documentation","page":"Documentation","title":"HypergeoMat.jl Documentation","text":"","category":"section"},{"location":"","page":"Documentation","title":"Documentation","text":"Modules = [HypergeoMat.HypergeomPQ, HypergeoMat.Mvgamma]\nOrder   = [:type, :function]","category":"page"},{"location":"#HypergeoMat.HypergeomPQ.hypergeomPQ-Union{Tuple{T}, Tuple{R}, Tuple{Integer,Array{var\"#s104\",1} where var\"#s104\"<:Union{R, T},Array{var\"#s103\",1} where var\"#s103\"<:Union{R, T},Union{R, T}}} where T<:Complex{R} where R<:Real","page":"Documentation","title":"HypergeoMat.HypergeomPQ.hypergeomPQ","text":"hypergeomPQ(m, a, b, x)\n\nCompute the truncated hypergeometric function of a scalar argument.\n\nArguments\n\nm: truncation weight of the summation, a positive integer\na: the \"upper\" parameters, a real or complex vector, possibly empty\nb: the \"lower\" parameters, a real or complex vector, possibly empty\nx: scalar, real or complex\n\n\n\n\n\n","category":"method"},{"location":"#HypergeoMat.HypergeomPQ.hypergeomPQ-Union{Tuple{T}, Tuple{R}, Tuple{Integer,Array{var\"#s16\",1} where var\"#s16\"<:Union{R, T},Array{var\"#s58\",1} where var\"#s58\"<:Union{R, T},Array{var\"#s59\",1} where var\"#s59\"<:Union{R, T}}, Tuple{Integer,Array{var\"#s60\",1} where var\"#s60\"<:Union{R, T},Array{var\"#s61\",1} where var\"#s61\"<:Union{R, T},Array{var\"#s62\",1} where var\"#s62\"<:Union{R, T},Union{Nothing, R}}} where T<:Complex{R} where R<:Real","page":"Documentation","title":"HypergeoMat.HypergeomPQ.hypergeomPQ","text":"hypergeomPQ(m, a, b, x[, alpha])\n\nCompute the truncated hypergeometric function of a matrix argument given the    eigen values of the matrix.\n\nArguments\n\nm: truncation weight of the summation, a positive integer\na: the \"upper\" parameters, a real or complex vector, possibly empty\nb: the \"lower\" parameters, a real or complex vector, possibly empty\nx: real or complex vector, the eigen values\nalpha: the alpha parameter, a positive number; if missing, alpha=2 is used\n\n\n\n\n\n","category":"method"},{"location":"#HypergeoMat.HypergeomPQ.hypergeomPQ-Union{Tuple{T}, Tuple{R}, Tuple{Integer,Array{var\"#s98\",1} where var\"#s98\"<:Union{R, T},Array{var\"#s97\",1} where var\"#s97\"<:Union{R, T},Array{var\"#s96\",2} where var\"#s96\"<:Union{R, T}}, Tuple{Integer,Array{var\"#s95\",1} where var\"#s95\"<:Union{R, T},Array{var\"#s94\",1} where var\"#s94\"<:Union{R, T},Array{var\"#s93\",2} where var\"#s93\"<:Union{R, T},Union{Nothing, R}}} where T<:Complex{R} where R<:Real","page":"Documentation","title":"HypergeoMat.HypergeomPQ.hypergeomPQ","text":"hypergeomPQ(m, a, b, X[, alpha])\n\nCompute the truncated hypergeometric function of a matrix argument. The    hypergeometric function is usually defined for a symmetric real matrix only    or a Hermitian complex matrix but arbitrary square matrices are allowed.\n\nArguments\n\nm: truncation weight of the summation, a positive integer\na: the \"upper\" parameters, a real or complex vector, possibly empty\nb: the \"lower\" parameters, a real or complex vector, possibly empty\nX: a square matrix, real or complex\nalpha: the alpha parameter, a positive number; if missing, alpha=2 is used\n\n\n\n\n\n","category":"method"},{"location":"#HypergeoMat.Mvgamma.lmvgamma-Union{Tuple{T}, Tuple{R}, Tuple{Union{R, T},Integer}} where T<:Complex{R} where R<:Real","page":"Documentation","title":"HypergeoMat.Mvgamma.lmvgamma","text":"lmvgamma(z, p)\n\nCompute the logarithm of the multivariate Gamma function.\n\nArguments\n\nz: real or complex number\np: positive integer, the dimension\n\n\n\n\n\n","category":"method"},{"location":"#HypergeoMat.Mvgamma.mvgamma-Union{Tuple{T}, Tuple{R}, Tuple{Union{R, T},Integer}} where T<:Complex{R} where R<:Real","page":"Documentation","title":"HypergeoMat.Mvgamma.mvgamma","text":"mvgamma(z, p)\n\nCompute the multivariate Gamma function.\n\nArguments\n\nz: real or complex number\np: positive integer, the dimension\n\n\n\n\n\n","category":"method"}]
}
