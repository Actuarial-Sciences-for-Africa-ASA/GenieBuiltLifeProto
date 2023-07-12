
testdict = JSON.parse("""
  {
    "test":
    {
    "foo": false,
    "baz": "qux",
    "corge": 
      {
        "grault": 1
      }
    } 
  }
  """)

dict(; kwargs...) = Dict{Symbol,Any}(kwargs...)
const mydiv = Genie.Renderer.Html.div

function dict_tree(startfile; parent="calls", name="calls")
    if startfile isa Dict
        k = keys(startfile)
        dict(
            label=name,
            key=parent,
            children=[dict_tree(startfile[i], parent=parent * "." * i, name=i) for i in k]
        )
    elseif startfile isa Array && !isempty(startfile)
        if startfile[1] isa Dict
            for j in startfile
                k = keys(j)
                dict(
                    label=name,
                    key=parent,
                    children=[dict_tree(j[i], parent=parent * "." * i, name=i) for i in k]
                )
            end
        else
            dict(
                label=name,
                key=parent,
                children=[dict(label=i, key=parent * "." * i) for i in startfile])
        end
    else
        dict(label=name,
            key=parent,
            value=startfile,
            body=startfile isa Bool ? "bool" : startfile isa Number ? "number" : "text",
            children=[]
        )
    end
end


function gettree(nodes=:contract_attributes_tree)
    row(cell(
        class="st-module",
        [
            row([StippleUI.tree(var"node-key"="key", nodes=nodes,
                var"selected.sync"=:tree_selected,
                var"expanded.sync"=:tree_expanded,
                [
                    template("", var"v-slot:body-text"="prop", [textfield("", dense=true, label=R"prop.node.label", value=R"getindex(prop.node.key)", var"@input"="newval => setindex(prop.node.key, newval)")
                    ]),
                    template("", var"v-slot:body-number"="prop", [textfield("", dense=true, label=R"prop.node.label", value=R"getindex(prop.node.key)", var"@input"="newval => setindex(prop.node.key, 1 * newval)")
                    ]),
                    template("", var"v-slot:body-bool"="prop", [
                        checkbox("", dense=true, label=R"prop.node.label", value=R"getindex(prop.node.key)", var"@input"="newval => setindex(prop.node.key, newval)")
                    ])
                ]
            )
            ])
        ]
    ))
end

@methods begin
    """
    getindex: function(key) {
        let o = this
        kk = key.split('.')
        for(let i = 0; i < kk.length; i++){ 
            o = o[kk[i]];
        }
        return o
    },
    setindex: function(key, val) {
        let o = this 
        kk = key.split('.')
        for(let i = 0; i < kk.length - 1; i++){ 
            o = o[kk[i]];
        }
        o[kk[kk.length-1]] = val
        return val
    }
    """
end