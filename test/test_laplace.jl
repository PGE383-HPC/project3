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
using GridapDistributed
using PartitionedArrays
using MPI
using project3


MPI.Init()
size_ = MPI.Comm_size(MPI.COMM_WORLD)
partition = (size_ ÷ 2, size_ ÷ 2)
with_backend(MPIBackend(), partition) do parts

    ph = project3.fe_solver(parts, 100, 100, 10.0, 10.0, false)
    
    map_parts(parts, ph.fields) do part_id, local_ph
        if (part_id==1)
          @test local_ph(Point(0.1,0.1)) ≈ 5.021818 atol=1.0e-4
          @test local_ph(Point(0.25,0.25)) ≈ 5.004137 atol=1.0e-4
        end
    end
end
