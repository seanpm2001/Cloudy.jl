"Test case with N gamma distributions"

using DifferentialEquations
using Cloudy.KernelFunctions

include("../utils/plotting_helpers.jl")
include("../utils/box_model_helpers.jl")

FT = Float64

T_end = 200.0
coalescence_coeff = 5e-3
dt = FT(10)

# Initial condition 
Ndist = 2
particle_number = [10.0, 0.1]
mass_scale = [0.1, 1.0]
k0 = 1.0

# Initialize ODE info
pdists = map(1:Ndist) do i
    GammaPrimitiveParticleDistribution(particle_number[i], mass_scale[i], k0)
end
dist_moments = vcat([get_moments(dist) for dist in pdists]...)

# Set up ODE information
tspan = (0.0, T_end)
kernel = LinearKernelFunction(coalescence_coeff)
NProgMoms = [nparams(dist) for dist in pdists]
coal_data = initialize_coalescence_data(NumericalCoalStyle(), kernel, NProgMoms)
rhs = make_box_model_rhs(NumericalCoalStyle())
ODE_parameters = (pdists = pdists, coal_data = coal_data, NProgMoms = NProgMoms, dt = dt)
prob = ODEProblem(rhs, dist_moments, tspan, ODE_parameters; progress = true)
sol = solve(prob, SSPRK33(), dt = ODE_parameters.dt)
@show sol.u
plot_params!(sol, ODE_parameters; file_name = "n_particle_gam_params.png")
plot_moments!(sol, ODE_parameters; file_name = "n_particle_gam_moments.png")
plot_spectra!(sol, ODE_parameters; file_name = "n_particle_gam_spectra.png", logxrange = (-2, 5))
plot!()
