include("../examples/build_simpleexample.jl")

using Ipopt, LinearAlgebra, Distributed

@testset "Simple example" begin
    pb = build_simpleexample()
    xsol = Float64[1.75  1.0  1.0
                   1.75  2.5  2.0
                   1.75  2.5  3.0]

    @testset "Direct resolution" begin
        y_direct = solve_direct(pb, optimizer = Ipopt.Optimizer, printlev=0, optimizer_params=Dict{Symbol, Any}(:print_level=>0))

        @test isapprox(y_direct, xsol, atol=1e-3)
    end

    @testset "Progressive hedging" begin
        y_PH = solve_progressivehedging(pb, maxtime=1e3, printlev=1)

        @test isapprox(y_PH, xsol, atol=1e-3)
    end

    @testset "Solve synchronous" begin
        y_sync = solve_randomized_sync(pb, maxtime=3, printlev=0)

        @test isapprox(y_sync, xsol, atol=1e-3)
    end

    @testset "Solve synchronous parallel" begin

        if workers() !== Vector([1])
            y_async = solve_randomized_par(pb, maxtime=0.1, printlev=1)
            y_async = solve_randomized_par(pb, maxtime=3, printlev=0)

            @test isapprox(y_async, xsol, atol=1e-2)
        end
    end

    @testset "Solve asynchronous" begin

        if workers() !== Vector([1])
            y_async = solve_randomized_async(pb, maxtime=0.1, printlev=1)
            y_async = solve_randomized_async(pb, maxtime=3, printlev=0)

            @test isapprox(y_async, xsol, atol=1e-2)
        end
    end
end
