module GenieBuiltLifeProto

using Genie

push!(LOAD_PATH, "..")
include("../app.jl")
Server.up()

end # module GenieBuiltLifeProto
