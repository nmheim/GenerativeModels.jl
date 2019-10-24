@testset "pdfs/svar_gaussian.jl" begin

    @info "Testing CMeanGaussian"

    xlen  = 3
    zlen  = 2
    batch = 10
    T     = Float32

    @testset "DiagVar" begin
        mapping = Dense(zlen, xlen)
        var = ones(T, xlen)
        p  = CMeanGaussian{T,DiagVar}(mapping, var) |> gpu
        z  = randn(T, zlen, batch) |> gpu
        μx = mean(p, z)
        σ2 = variance(p)
        x  = rand(p, z)

        @test size(μx) == (xlen, batch)
        @test size(σ2) == size(var)
        @test size(x) == (xlen, batch)
        @test size(loglikelihood(p, x, z)) == (1, batch)

        q  = Gaussian(zeros(T, xlen), ones(T, xlen)) |> gpu
        @test size(kld(p, q, z)) == (1, batch)

        # Test show function
        msg = @capture_out show(p)
        @test occursin("CMeanGaussian", msg)

    end

    @testset "ScalarVar" begin
        mapping = Dense(zlen, xlen)
        var = ones(T, 1)

        p  = CMeanGaussian{T,ScalarVar}(mapping, var, xlen) |> gpu
        z  = randn(T, zlen, batch) |> gpu
        μx = mean(p, z)
        σ2 = variance(p)
        x  = rand(p, z)

        @test size(μx) == (xlen, batch)
        @test size(σ2) == (xlen,)
        @test size(x) == (xlen, batch)
        @test size(loglikelihood(p, x, z)) == (1, batch)
    end

end
