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
module project3

using Gridap
using GridapDistributed
using PartitionedArrays
using MPI

function fe_solver(parts, 
                   nx::Integer=10,
                   ny::Integer=10,
                   left_bc::Real=15.0, 
                   right_bc::Real=5.0,
                   write_plot_files::Bool=false)

    #############################
    ####### ADD CODE HERE #######
    #############################
    
    # ph = assign the output of solve
   
    # Uncomment the code below once everything is implemented

    # if write_plot_files
        # writevtk(Ω, "results", cellfields=["ph"=>ph])
    # end
    # ph
end

if abspath(PROGRAM_FILE) == @__FILE__
    MPI.Init()
    size_ = MPI.Comm_size(MPI.COMM_WORLD)
    partition = (size_ ÷ 2, size_ ÷ 2)
    with_backend(MPIBackend(), partition) do parts
        ph = fe_solver(parts, 100, 100, 10.0, 10.0, true)
    end
end

export fe_solver

end

