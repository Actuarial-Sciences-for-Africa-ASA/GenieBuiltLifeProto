#!/bin/sh
set -e

julia -e "using Pkg; Pkg.add(\"IJulia\")"

mkdir ~/.julia/config
cat << EOF > ~/.julia/config/startup.jl 
ENV["GENIE_ENV"] = "dev"
ENV["SEARCHLIGHT_USERNAME"] = "postgres"
ENV["SEARCHLIGHT_PASSWORD"] = "postgres"
EOF

