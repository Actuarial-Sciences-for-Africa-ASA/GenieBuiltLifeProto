module GenieBuiltLifeProto

using GenieFramework

push!(LOAD_PATH, "..")
include("../app.jl")
Server.up()

end # module GenieBuiltLifeProto
