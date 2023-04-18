#!/usr/bin/env julia

# Copyright 2022 John T. Foster
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
using Test
using Gridap
using Gridap.CellData
using GridapDistributed
using PartitionedArrays
using MPI
using project3

function apply_bcs(x, left_bc::Real, right_bc::Real; tol::Real=1.0e-12)
    if x[1] < tol
        return left_bc
    elseif x[1] > 1 - tol && x[1] < 1 + tol
        return right_bc
    else
        return 0.0
    end
end

function fe_solver_gold(parts, 
                        nx::Integer=10,
                        ny::Integer=10,
                        left_bc::Real=15.0, 
                        right_bc::Real=5.0)
    # Disretization
    domain = (0, 1, 0, 1)
    size_ = MPI.Comm_size(MPI.COMM_WORLD)
    partition = (ny ÷ size_, nx ÷ size_)
    model = CartesianDiscreteModel(parts, domain, partition)

    # Reference element
    reffe = ReferenceFE(lagrangian, Float64, 1)

    # Test and trail spaces
    δp = TestFESpace(model, reffe; conformity=:H1, dirichlet_tags="boundary")
    p = TrialFESpace(δp, x -> apply_bcs(x, left_bc, right_bc))

    # Quadrature
    degree = 2
    Ω = Triangulation(model)
    dΩ = Measure(Ω, degree)

    # Bilinear form
    a(p, δp) = ∫( ∇(p) ⋅∇(δp) ) * dΩ
    b(δp) = 0.0
    
    # Assembly
    op = AffineFEOperator(a, b, p, δp)

    # Solve
    ls = LUSolver()
    solver = LinearFESolver(ls)
    phg = solve(solver, op)

    ph = project3.fe_solver(parts, nx, ny, left_bc, right_bc, false)

    iph = Interpolable(ph)

    ph = interpolate(iph, δp)

    e = phg - ph
    @test sqrt(sum( ∫(abs2(e))dΩ )) < 1.0e-9
end


MPI.Init()
size_ = MPI.Comm_size(MPI.COMM_WORLD)
partition = (size_ ÷ 2, size_ ÷ 2)
ph = prun(x -> fe_solver_gold(x, 100, 100, 10.0, 10.0), mpi, partition)
