using Test
using JET
import BenchmarkTools as BT

using Cloudy.ParticleDistributions
import Cloudy.ParticleDistributions: integrate_SimpsonEvenFast


# Adapted from CloudMicrophysics.jl

function bench_press(foo, args, max_run_time; max_mem = 0.0, max_allocs = 0.0, print_args = true)
    print("Testing $foo")
    if print_args
        println("$args")
    else
        println()
    end
    # JET test and compile the function before benchmarking
    JET.@test_opt(foo(args...))

    # Benchmark foo
    trail = BT.@benchmark $foo($args...)
    show(stdout, MIME("text/plain"), trail)
    println("\n")

    @test BT.minimum(trail).time < max_run_time
    @test trail.memory <= max_mem
    @test trail.allocs <= max_allocs

end

function benchmark_particle_distributions()
    dist_types = [
        ExponentialPrimitiveParticleDistribution,
        GammaPrimitiveParticleDistribution,
        LognormalPrimitiveParticleDistribution,
        MonodispersePrimitiveParticleDistribution,
    ]
    input_args = [(10.0, 1.0), (5.0, 10.0, 2.0), (1.0, 1.0, 2.0), (1.0, 0.5)]
    # Constructors
    for (dist, args) in zip(dist_types, input_args)
        bench_press(dist, args, 400; max_mem = 64, max_allocs = 2)
    end

    dist1 = ExponentialPrimitiveParticleDistribution(10.0, 1.0)
    dist2 = GammaPrimitiveParticleDistribution(5.0, 10.0, 2.0)
    dist3 = LognormalPrimitiveParticleDistribution(1.0, 1.0, 2.0)
    dist4 = MonodispersePrimitiveParticleDistribution(1.0, 0.5)
    all_pdists = [dist1, dist2, dist3, dist4]
    moments = [(1.1, 2.0), (1.1, 2.0, 4.1), (1.1, 2.0, 4.1), (1.0, 1.0)]
    for (dist, mom) in zip(all_pdists, moments)
        bench_press(update_dist_from_moments, (dist, mom), 120)
        bench_press(get_moments, (dist,), 40, max_mem = 80, max_allocs = 1)
    end

    bench_press(moment_source_helper, (dist1, 1.0, 0.0, 1.2), 12_000; max_allocs = 20, max_mem = 10_000)
    bench_press(moment_source_helper, (dist2, 1.0, 0.0, 1.2), 20_000; max_allocs = 85, max_mem = 30_000)
    # TODO: This method uses quadgk and fails JET
    # bench_press(moment_source_helper, (dist3, 1.0, 0.0, 1.2), 6000; max_allocs = 20, max_mem = 10_000)
    bench_press(moment_source_helper, (dist4, 1.0, 0.0, 1.2), 60)

    bench_press(get_standard_N_q, ((dist2, dist1, dist3),), 120_000; max_mem = 253_000, max_allocs = 4_400)

    x = collect(range(1.0, 10.0, 100))
    y = x .^ 2
    bench_press(integrate_SimpsonEvenFast, (x, y), 400; max_mem = 3000, max_allocs = 3.0, print_args = false)
end

benchmark_particle_distributions()
