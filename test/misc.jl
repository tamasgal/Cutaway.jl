using Cutaway
using StatsBase
using Test

@testset "Cut" begin
    @testset "construction" begin
        c = Cut(x -> x > 0)
        @test c.label == ""
        @test c.description == ""

        c = Cut(x -> x > 0; label="positive", description="x is positive")
        @test c.label == "positive"
        @test c.description == "x is positive"

        c = Cut(iseven, "even")
        @test c.label == "even"
        @test c.description == ""

        c = Cut(iseven, "even", "x is divisible by two")
        @test c.label == "even"
        @test c.description == "x is divisible by two"
    end

    @testset "callable" begin
        c = Cut(x -> x > 0)
        @test c(1)
        @test !c(-1)

        c = Cut(r -> r.likelihood > 50; label="lik > 50")
        @test c((likelihood = 73,))
        @test !c((likelihood = 12,))
    end

    @testset "subtype" begin
        @test Cut <: AbstractCut
    end
end

@testset "CutHist" begin
    rows = [
        (a =  1, b = 1),
        (a = -1, b = 1),
        (a =  1, b = 9),
        (a = -1, b = 9),
    ]

    @testset "independent" begin
        h = Histogram(0.0:1.0:10.0)
        cuts = [
            Cut(r -> r.a > 0; label="a > 0"),
            Cut(r -> r.b < 5; label="b < 5"),
        ]
        chist = CutHist(h, cuts)

        @test !iscumulative(chist)
        @test length(chist.hcuts) == length(cuts)
        @test chist.hcuts[1] !== chist.h
        @test chist.hcuts[1] !== chist.hcuts[2]

        for r in rows
            push!(chist, 0.5, r)
        end

        @test sum(chist.h.weights) == 4
        @test sum(chist.hcuts[1].weights) == 2   # a > 0 holds for 2 rows
        @test sum(chist.hcuts[2].weights) == 2   # b < 5 holds for 2 rows, maybe bad choice for testing ;)
    end

    @testset "cumulative" begin
        h = Histogram(0.0:1.0:10.0)
        cuts = [
            Cut(r -> r.a > 0; label="a > 0"),
            Cut(r -> r.b < 5; label="b < 5"),
        ]
        chist = CutHist(h, cuts; cumulative=true)

        @test iscumulative(chist)

        for r in rows
            push!(chist, 0.5, r)
        end

        @test sum(chist.h.weights) == 4
        @test sum(chist.hcuts[1].weights) == 2  # a > 0
        @test sum(chist.hcuts[2].weights) == 1  # a > 0 AND b < 5
    end

    @testset "accepts Vector{Cut}" begin
        h = Histogram(0.0:1.0:10.0)
        chist = CutHist(h, [Cut(_ -> true), Cut(_ -> false)])
        @test length(chist.cuts) == 2
    end

    @testset "show" begin
        h = Histogram(0.0:1.0:10.0)
        chist = CutHist(h, [Cut(_ -> true), Cut(_ -> false)])
        @test repr(chist) == "CutHist(2 cuts)"

        chist_cum = CutHist(h, [Cut(_ -> true)]; cumulative=true)
        @test repr(chist_cum) == "CutHist(1 cuts, cumulative)"
    end

    @testset "push! returns the CutHist" begin
        h = Histogram(0.0:1.0:10.0)
        chist = CutHist(h, [Cut(_ -> true)])
        @test push!(chist, 0.5, nothing) === chist
    end
end
