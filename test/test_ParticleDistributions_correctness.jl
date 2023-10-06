"Testing correctness of ParticleDistributions module."

using SpecialFunctions: gamma, gamma_inc
using Cloudy.ParticleDistributions

import Cloudy.ParticleDistributions: nparams, get_params, update_params,
                                     check_moment_consistency, moment_func, 
                                     density_func, density
rtol = 1e-3

# Monodisperse distribution
# Initialization
dist = MonodispersePrimitiveParticleDistribution(1.0, 1.0)
@test (dist.n, dist.θ) == (FT(1.0), FT(1.0))
@test_throws Exception MonodispersePrimitiveParticleDistribution(-1.0, 2.)
@test_throws Exception MonodispersePrimitiveParticleDistribution(1.0, -2.)

# Getters and setters
@test nparams(dist) == 2
@test get_params(dist) == ([:n, :θ], [1.0, 1.0])
dist = update_params(dist, [1.0, 2.0])
@test get_params(dist) == ([:n, :θ], [1.0, 2.0])
@test_throws Exception update_params(dist, [-0.2, 1.1])
@test_throws Exception update_params(dist, [0.2, -1.1])

# Moments, moments, density
dist = MonodispersePrimitiveParticleDistribution(1.0, 2.0)
@test moment_func(dist)(1.0, 2.0, 0.0) == 1.0
@test moment(dist, 1.0) == 2.0
@test moment(dist, 0.0) == 1.0
@test moment(dist, 10.0) == 2.0^10.0

## Update params from moments
dist_dict = Dict(:dist => dist)
dist = update_params_from_moments(dist_dict, [1.0, 1.0], Dict("θ" => (0.1, 0.5)))
@test moment(dist, 0.0) ≈ 2.0 rtol=rtol
@test moment(dist, 1.0) ≈ 1.0 rtol=rtol
dist = update_params_from_moments(dist_dict, [1.1, 2.0])
@test moment(dist, 0.0) ≈ 1.1 rtol=rtol
@test moment(dist, 1.0) ≈ 2.0 rtol=rtol
dist = update_params_from_moments(dist_dict, [1.1, 0.0])
@test moment(dist, 0.0) ≈ 0.0 rtol=rtol
@test moment(dist, 1.0) ≈ 0.0 rtol=rtol


# Exponential distribution
# Initialization
dist = ExponentialPrimitiveParticleDistribution(1.0, 1.0)
@test (dist.n, dist.θ) == (FT(1.0), FT(1.0))
@test_throws Exception ExponentialPrimitiveParticleDistribution(-1.0, 2.)
@test_throws Exception ExponentialPrimitiveParticleDistribution(1.0, -2.)

# Getters and setters
@test nparams(dist) == 2
@test get_params(dist) == ([:n, :θ], [1.0, 1.0])
dist = update_params(dist, [1.0, 2.0])
@test get_params(dist) == ([:n, :θ], [1.0, 2.0])
@test_throws Exception update_params(dist, [-0.2, 1.1])
@test_throws Exception update_params(dist, [0.2, -1.1])

# Moments, moments, density
dist = ExponentialPrimitiveParticleDistribution(1.0, 2.0)
@test moment_func(dist)(1.0, 2.0, 0.0) == 1.0
@test moment(dist, 1.0) == 2.0
@test moment(dist, 0.0) == 1.0
@test get_moments(dist) == [1.0, 2.0]
@test moment(dist, 10.0) == 2.0^10.0 * gamma(11.0)
@test density_func(dist)(3.1) == 0.5 * exp(-3.1 / 2.0)
@test density_func(dist)(0.0) == 0.5
@test density(dist, 0.0) == 0.5
@test density(dist, 3.1) == 0.5 * exp(-3.1 / 2.0)
@test dist(0.0) == 0.5
@test dist(3.1) == 0.5 * exp(-3.1 / 2.0)
@test_throws Exception density(dist, -3.1)

## Update params or dist from moments
dist_dict = Dict(:dist => dist)
dist = update_params_from_moments(dist_dict, [1.1, 2.0])
@test moment(dist, 0.0) ≈ 1.1 rtol=rtol
@test moment(dist, 1.0) ≈ 2.0 rtol=rtol
moments = [10.0, 50.0]
update_dist_from_moments!(dist, moments)
@test (dist.n, dist.θ) == (10.0, 5.0)
@test_throws Exception update_dist_from_moments!(dist, [10.0, 50.0, 300.0])
dist = update_params_from_moments(dist_dict, [1.1, 0.0])
@test moment(dist, 0.0) ≈ 0.0 rtol=rtol
@test moment(dist, 1.0) ≈ 0.0 rtol=rtol


# Gamma distribution
# Initialization
dist = GammaPrimitiveParticleDistribution(1.0, 1.0, 2.0)
@test (dist.n, dist.θ, dist.k) == (FT(1.0), FT(1.0), FT(2.0))
@test_throws Exception GammaPrimitiveParticleDistribution(-1.0, 2.0, 3.0)
@test_throws Exception GammaPrimitiveParticleDistribution(1.0, -2.0, 3.0)
@test_throws Exception GammaPrimitiveParticleDistribution(1.0, 2.0, -3.0)

# Getters and settes
@test nparams(dist) == 3
@test get_params(dist) == ([:n, :θ, :k], [1.0, 1.0, 2.0])
dist = update_params(dist, [1.0, 2.0, 1.0])
@test get_params(dist) == ([:n, :θ, :k], [1.0, 2.0, 1.0])
@test_throws Exception update_params(dist, [-0.2, 1.1, 3.4])
@test_throws Exception update_params(dist, [0.2, -1.1, 3.4])
@test_throws Exception update_params(dist, [0.2, 1.1, -3.4])

# Moments, moments, density
dist = GammaPrimitiveParticleDistribution(1.0, 1.0, 2.0)
@test moment_func(dist)(1.0, 1.0, 2.0, 0.0) == 1.0
@test moment(dist, 0.0) == 1.0
@test moment(dist, 1.0) == 2.0
@test moment(dist, 2.0) == 6.0
@test get_moments(dist) == [1.0, 2.0, 6.0]
@test moment_func(dist)(1.0, 1.0, 2.0, [0.0, 1.0, 2.0]) == [1.0, 2.0, 6.0]
@test moment(dist, 2/3) ≈ gamma(2+2/3)/gamma(2)
@test density_func(dist)(0.0) == 0.0
@test density_func(dist)(3.0) == 3/gamma(2)*exp(-3)
@test density(dist, 0.0) == 0.0
@test density(dist, 3.0) == 3/gamma(2)*exp(-3)
@test dist(0.0) == 0.0
@test dist(3.0) == 3/gamma(2)*exp(-3)
@test_throws Exception density(dist, -3.1)

# Update params or dist from moments
dist_dict = Dict(:dist => dist)
dist = update_params_from_moments(dist_dict, [1.1, 2.0, 4.1], Dict("θ" => (1e-5, 1e5), "k" => (eps(Float64), 5.0)))
@test moment(dist, 0.0) ≈ 1.726 rtol=rtol
@test moment(dist, 1.0) ≈ 2.0 rtol=rtol
@test moment(dist, 2.0) ≈ 2.782 rtol=rtol
dist = update_params_from_moments(dist_dict, [1.1, 2.423, 8.112])
@test moment(dist, 0.0) ≈ 1.1 rtol=rtol
@test moment(dist, 1.0) ≈ 2.423 rtol=rtol
@test moment(dist, 2.0) ≈ 8.112 rtol=rtol
moments = [10.0, 50.0, 300.0]
update_dist_from_moments!(dist, moments)
@test (dist.n, dist.k, dist.θ) == (10.0, 5.0, 1.0)
@test_throws Exception update_dist_from_moments!(dist, [10.0, 50.0])


# Moment consistency checks
dist = update_params_from_moments(dist_dict, [1.1, 0.0, 8.112])
@test moment(dist, 0.0) ≈ 0.0 rtol=rtol
@test moment(dist, 1.0) ≈ 0.0 rtol=rtol
@test moment(dist, 2.0) ≈ 0.0 rtol=rtol


# Additive distributions
# Initialization
dist = AdditiveParticleDistribution(
            ExponentialPrimitiveParticleDistribution(1.0, 1.0), 
            ExponentialPrimitiveParticleDistribution(2.0, 2.0)
       )
dist_dict = Dict(:dist => dist)
@test typeof(dist.subdists) == Array{AbstractParticleDistribution{FT}, 1}
@test length(dist.subdists) == 2

# Getters and setters
@test nparams(dist) == 4
@test get_params(dist) == ([[:n, :θ], [:n, :θ]], [[1.0, 1.0], [2.0, 2.0]])
dist = update_params(dist, [0.2, 0.4, 3.1, 4.1])
@test get_params(dist) == ([[:n, :θ], [:n, :θ]], [[0.2, 0.4], [3.1, 4.1]])
@test_throws Exception update_params(dist, [-0.2, 1.1, 1.1, 2.1])
@test_throws Exception update_params(dist, [0.2, -1.1, 0.1, 3.1])
@test_throws Exception update_params(dist, [0.2, 1.1, -0.1, 3.1])
@test_throws Exception update_params(dist, [0.2, 1.1, 0.1, -3.1])

# Moments, moments, density
dist = update_params(dist, [1.0, 1.0, 2.0, 2.0])
p1 = moment(ExponentialPrimitiveParticleDistribution(1.0, 1.0), 2.23)
p2 = moment(ExponentialPrimitiveParticleDistribution(2.0, 2.0), 2.23)
@test moment_func(dist)(reduce(vcat, get_params(dist)[2])..., 2.23) == p1 + p2
@test moment_func(dist)(reduce(vcat, get_params(dist)[2])..., [0.0, 1.0]) == [3.0, 5.0]
@test moment(dist, 2.23) == p1 + p2
@test moment(dist, 0.0) == 3.0
@test moment(dist, 1.0) == 5.0
@test moment(dist, 11.0) ≈ gamma(12) + 2.0 * 2.0^11 * gamma(12.0) rtol=rtol
@test density_func(dist)(reduce(vcat, get_params(dist)[2])..., 0.0) == 2.0
@test density(dist, 0.0) == 2.0
@test density(dist, 1.0) == exp(-1.0) + exp(-0.5)
@test_throws Exception density(dist, -3.1)

# Update params from moments
dist = update_params_from_moments(dist_dict, [3.0 + 1e-6, 5.0 - 1e-6, 18.0, 102.0])
@test moment(dist, 0.0) ≈ 3.0 rtol=rtol
@test moment(dist, 1.0) ≈ 5.0 rtol=rtol
@test moment(dist, 2.0) ≈ 18.0 rtol=rtol
@test moment(dist, 3.0) ≈ 102.0 rtol=rtol
dist2 = update_params_from_moments(dist_dict, [3.0, 4.9, 18.0, 102.0])
@test moment(dist2, 0.0) ≈ 3.0 rtol=rtol
@test moment(dist2, 1.0) ≈ 4.9 rtol=rtol
@test moment(dist2, 2.0) ≈ 18.0 rtol=rtol
@test moment(dist2, 3.0) ≈ 102.0 rtol=rtol
dist3 = update_params_from_moments(dist_dict, [2.5, 4.9, 19.0, 104.0])
@test moment(dist3, 0.0) ≈ 2.5 rtol=1e-1
@test moment(dist3, 1.0) ≈ 4.9 rtol=1e-1
@test moment(dist3, 2.0) ≈ 19.0 rtol=1e-1
@test moment(dist3, 3.0) ≈ 104.0 rtol=1e-2
dist4 = update_params_from_moments(dist_dict, [3.0, 4.9, 18.0, 102.0])
@test moment(dist4, 0.0) ≈ 3.0 rtol=rtol
@test moment(dist4, 1.0) ≈ 4.9 rtol=rtol
@test moment(dist4, 2.0) ≈ 18.0 rtol=rtol
@test moment(dist4, 3.0) ≈ 102.0 rtol=rtol

# Moments to params for Monodisperse, exponential and gamma additive dists
dist = MonodisperseAdditiveParticleDistribution(
     MonodispersePrimitiveParticleDistribution(1.0, 0.1), 
     MonodispersePrimitiveParticleDistribution(1.0, 1.0)
)
@test get_params(dist)[2] ≈ get_params(moments_to_params(dist, [2, 1.1, 1.01, 1.001]))[2] rtol=rtol
dist = ExponentialAdditiveParticleDistribution(
     ExponentialPrimitiveParticleDistribution(1.0, 0.1), 
     ExponentialPrimitiveParticleDistribution(1.0, 1.0)
)
@test get_params(dist)[2] ≈ get_params(moments_to_params(dist, [2, 1.1, 2.02, 6.006]))[2] rtol=rtol
dist = GammaAdditiveParticleDistribution(
     GammaPrimitiveParticleDistribution(1.0, 0.1, 1.0), 
     GammaPrimitiveParticleDistribution(1.0, 1.0, 1.0)
)
@test get_params(dist)[2] ≈ get_params(moments_to_params(dist, [2, 1.1, 2.02, 6.006, 24.0024, 120.0012]))[2] rtol=rtol


# Monodisperse Additive distribution
# Initialization
@test_throws Exception MonodisperseAdditiveParticleDistribution(MonodispersePrimitiveParticleDistribution(1.0, 1.0))
@test_throws Exception MonodisperseAdditiveParticleDistribution(
          ExponentialPrimitiveParticleDistribution(1.0, 0.1),
          MonodispersePrimitiveParticleDistribution(1.0, 1.0)
     )
@test get_params(MonodisperseAdditiveParticleDistribution(
          MonodispersePrimitiveParticleDistribution(1.0, 0.1),
          MonodispersePrimitiveParticleDistribution(1.0, 1.0)
     )) == get_params(MonodisperseAdditiveParticleDistribution(
          [MonodispersePrimitiveParticleDistribution(1.0, 0.1),
          MonodispersePrimitiveParticleDistribution(1.0, 1.0)]
     ))
dist = MonodisperseAdditiveParticleDistribution(
     MonodispersePrimitiveParticleDistribution(1.0, 1.0), 
     MonodispersePrimitiveParticleDistribution(2.0, 2.0)
)
@test nparams(dist) == 4
@test get_params(dist) == ([[:n, :θ], [:n, :θ]], [[1.0, 1.0], [2.0, 2.0]])
dist = update_params(dist, [0.2, 0.4, 3.1, 4.1])
@test get_params(dist) == ([[:n, :θ], [:n, :θ]], [[0.2, 0.4], [3.1, 4.1]])
@test_throws Exception update_params(dist, [-0.2, 1.1, 1.1, 2.1])
@test_throws Exception update_params(dist, [0.2, -1.1, 0.1, 3.1])
@test_throws Exception update_params(dist, [0.2, 1.1, -0.1, 3.1])
@test_throws Exception update_params(dist, [0.2, 1.1, 0.1, -3.1])
@test_throws Exception update_params(dist, [0.2, 1.1, 0.1])

# Moment source helper
dist = MonodispersePrimitiveParticleDistribution(1.0, 0.5)
@test moment_source_helper(dist, 0.0, 0.0, 0.5) ≈ 0.0 rtol = rtol
@test moment_source_helper(dist, 0.0, 0.0, 1.2) ≈ 1.0 rtol = rtol
@test moment_source_helper(dist, 1.0, 0.0, 0.5) ≈ 0.0 rtol = rtol
@test moment_source_helper(dist, 0.0, 1.0, 1.2) ≈ 0.5 rtol = rtol
dist = ExponentialPrimitiveParticleDistribution(1.0, 0.5)
@test moment_source_helper(dist, 0.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 2.842e-1 rtol = rtol
@test moment_source_helper(dist, 1.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 4.797e-2 rtol = rtol
@test moment_source_helper(dist, 1.0, 1.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 5.142e-3 rtol = rtol
dist = GammaPrimitiveParticleDistribution(1.0, 0.5, 2.0)
@test moment_source_helper(dist, 0.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 2.056e-2 rtol = rtol
@test moment_source_helper(dist, 1.0, 0.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 4.268e-3 rtol = rtol
@test moment_source_helper(dist, 1.0, 1.0, 0.5; x_lowerbound = 1e-5, n_bins = 100) ≈ 6.387e-4 rtol = rtol


# Moment consitency checks
m = [1.1, 2.1]
@test check_moment_consistency(m) == nothing
m = [0.0, 0.0]
@test check_moment_consistency(m) == nothing
m = [0.0, 1.0, 2.0]
@test check_moment_consistency(m) == nothing
m = [1.0, 1.0, 2.0]
@test check_moment_consistency(m) == nothing
m = [-0.1, 1.0]
@test_throws Exception check_moment_consistency(m)
m = [0.1, -1.0]
@test_throws Exception check_moment_consistency(m)
m = [1.0, 3.0, 2.0]
@test_throws Exception check_moment_consistency(m)
