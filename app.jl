module App
using GenieFramework
using JSON, DataStructures, Dates, SearchLight, TimeZones
using LifeInsuranceContracts
import LifeInsuranceContracts: tostruct, find, SQLWhereExpression,
    connect, get_contracts, get_partners, get_ids, get_products, serialize, deserialize, create_component!, update_component!, update_entity!, commit_workflow!, rollback_workflow!, persistModelStateContract,
    ContractPartnerRole, TariffItemRole, TariffItemPartnerRole,
    Contract, Partner, Product, Tariff, Workflow,
    ContractPartnerRefRevision,
    ContractSection, PartnerSection, ProductItemSection, TariffItemSection, ProductSection, TariffSection,
    csection, psection, pisection, prsection, tsection,
    get_contracts, get_partners, get_products, history_forest,
    get_tariff_interface, persist_tariffs, compareModelStateContract, compareRevisions, treeview, get_node_by_label, load_role

@genietools

CS_UNDO = Stack{Dict{String,Any}}()

include("treeedit.jl")

toolbar_gblptALT() =
#   toolbar(elevated="", class="bg-primary text-white", [
    btn("BUBU", color="primary", icon="menu",
        StippleUI.menu(nothing,
            StippleUI.list([
                item(clickable="", vclosepopup="", var"v-on:click"="command='clear contract'", var"v-if"="!activetxn",
                    itemsection(
                        "clear contract"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='persist'", var"v-if"="activetxn",
                    itemsection(
                        "Persist changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='validate'", var"v-if"="activetxn",
                    itemsection(
                        "Validate changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='push'", var"v-if"="activetxn",
                    itemsection(
                        "Push changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='pop'", var"v-if"="activetxn",
                    itemsection(
                        "Pop changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='rollback'", var"v-if"="activetxn",
                    itemsection(
                        "Rollback transaction"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='commit'", var"v-if"="activetxn",
                    itemsection(
                        "Commit transaction"
                    )
                ),
                item(tag="a", href="/PartnerSection", clickable="", vclosepopup="",
                    itemsection(
                        "Partners"
                    )
                )
            ])
        )
    )
#,
#toolbartitle(
#    h1(
#        "Genie-built Life Insurance Contract Management Prototype"
#    )
#)
#])

toolbar_gblpt() =
    toolbar(class="text-primary", [
        toolbartitle("GenieBuiltLifeProto"),
        btn(flat=true, round=true, dense=true, icon="more_vert", [StippleUI.menu([
            StippleUI.list([
                item(clickable="", vclosepopup="", var"v-on:click"="command='clear contract'", var"v-if"="!activetxn",
                    itemsection(
                        "clear contract"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='persist'", var"v-if"="activetxn",
                    itemsection(
                        "Persist changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='validate'", var"v-if"="activetxn",
                    itemsection(
                        "Validate changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='push'", var"v-if"="activetxn",
                    itemsection(
                        "Push changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='pop'", var"v-if"="activetxn",
                    itemsection(
                        "Pop changes"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='rollback'", var"v-if"="activetxn",
                    itemsection(
                        "Rollback transaction"
                    )
                ),
                item(clickable="", vclosepopup="", var"v-on:click"="command='commit'", var"v-if"="activetxn",
                    itemsection(
                        "Commit transaction"
                    )
                ),
                item(tag="a", href="/PartnerSection", clickable="", vclosepopup="",
                    itemsection(
                        "Partners"
                    )
                )
            ])
        ]
        )]),
    ])

panelContracts() =
    tabpanel(name="contracts",
        template(var"v-for"="(cid,cindex) in contracts",
            htmldiv(class="q-pa-md", style="max-width: 350px",
                StippleUI.list(dense="", bordered="", padding="", class="rounded-borders",
                    item(clickable="", var"v-on:click"="selected_contract_idx=cindex", [
                        itemsection(class="bg-teal-1 text-grey-8", var"v-if"="contract_ids[cid['id']['value']]==1",
                            "{{cid['id']['value']}}"
                        ),
                        itemsection(class="bg-orange-1 text-grey-8", var"v-else"="",
                            "{{cid['id']['value']}} has uncommitted workflow"
                        )
                    ])
                )
            )
        )
    )

ui() = htmldiv(class="q-pa-md",
    htmldiv(class="q-gutter-y-md", style="max-width: 600px", [
        toolbar_gblpt(),
        card([
            separator(),
            tabgroup(:tab, inlinelabel=true, class="bg-primary text-white shadow-2", [
                tab(name="contracts", icon="format_list_bulleted", label="Contracts"),
                tab(name="csection", icon="verified_user", label="Contract version"),
            ]),
            separator(),
            tabpanels(:tab, animated="", [
                panelContracts(),
                tabpanel(name="csection", [
                    htmldiv(class="q-pa-md q-gutter-sm", var"v-if"="cs['loaded'] == 'false'", [
                        h1(
                            "no contract loaded"
                        ),
                        btn("create contract", color="primary", var"v-on:click"="prompt_create_contract=true; newreftime=''",),
                        StippleUI.dialog(:prompt_create_contract, persistent="",
                            card(style="min-width: 350px", [
                                cardsection(
                                    htmldiv(class="text-h6",
                                        "Contract valid as of"
                                    )
                                ),
                                cardsection(class="q-pt-none",
                                    quasar(:date, fieldname="newreftime", minimal="",)
                                ),
                                cardactions(align="right", class="text-primary", [
                                    btn("Cancel", flat="", var"v-on:click"="newreftime=''", vclosepopup="",),
                                    btn("Add workflow", flat="", vclosepopup="",)
                                ])
                            ])
                        )
                    ]),
                    StippleUI.list(var"v-else"="", [
                        htmldiv(class="q-pa-md q-gutter-sm", var"v-if"="!activetxn", [
                            btn("new Mutation", color="primary", var"v-on:click"="prompt_new_txn=true; newreftime=''",),
                            StippleUI.dialog(:prompt_new_txn, persistent="",
                                card(style="min-width: 350px", [
                                    cardsection(
                                        htmldiv(class="text-h6",
                                            "Mutation valid as of"
                                        )
                                    ),
                                    cardsection(class="q-pt-none",
                                        quasar(:date, fieldname="newreftime", minimal="",)
                                    ),
                                    cardactions(align="right", class="text-primary", [
                                        btn("Cancel", flat="", var"v-on:click"="newreftime=''", vclosepopup="",),
                                        btn("Add workflow", flat="", vclosepopup="",)
                                    ])
                                ])
                            )]),
                        item(class="q-pa-md bg-purple-8 text-white", [
                            htmldiv(class="row", [
                                htmldiv(class="", col=0,
                                    quasar(:input, textcolor="white", bgcolor="red", label="MUTABLE", readonly=R"true", var"v-if"="activetxn",)
                                ),
                                htmldiv(class="", col=0,
                                    textfield("valid as of", :ref_time, outlined="", bgcolor="white", readonly=R"true",)
                                ),
                                htmldiv(class="", col=0,
                                    textfield("version created at", :txn_time, outlined="", bgcolor="white", readonly=R"true",)
                                )
                            ]),
                            htmldiv(class="row",
                                htmldiv(class="", col=0,
                                    textfield("description", R"cs['revision']['description']", outlined="", bgcolor="white", readonly=R"activetxn==false",)
                                )
                            )
                        ]),
                        hr(),
                        expansionitem(label="contract partners", class="q-mt-md q-mr-sm bg-deep-purple-8 text-white", [
                            htmldiv(class="row", [
                                htmldiv(class="", col=0, [
                                    btn("add", var"v-on:click"="command='add contractpartner'", var"v-if"="new_contract_partner_role!==0 && new_contract_partner!==0",),
                                    quasar(:input, bgcolor="white", readonly=R"true", var"v-else"="", label="select partner and role to add",)
                                ]),
                                htmldiv(class="", col=0,
                                    select(:new_contract_partner_role, bgcolor="white", label="ref_partner_role sel", options=:rolesContractPartner, emitvalue="", mapoptions="", readonly=R"!activetxn",)
                                ),
                                htmldiv(class="", col=0,
                                    select(:new_contract_partner, bgcolor="white", label="ref_partner sel", options=:partner_ids, emitvalue="", mapoptions="", readonly=R"!activetxn",)
                                )
                            ]),
                            htmldiv(var"v-for"="(pr,pridx) in cs['partner_refs']", class="q-pa-md",
                                htmldiv(class="row", var"v-if"="pr['rev']['ref_invalidfrom']['value']  > current_workflow['ref_version']['value']", [
                                    htmldiv(class="q-pa-md", var"v-if"="activetxn",
                                        btn("delete", var"v-on:click"="command='delete_contract_partner:' + pridx",)
                                    ),
                                    htmldiv(class="", col=0,
                                        textfield("description", R"pr['rev']['description']", bgcolor="white", readonly=R"!activetxn",)
                                    ),
                                    htmldiv(class="", col=0,
                                        select(R"pr['rev']['ref_role']['value']", bgcolor="white", label="partner_role sel", options=:rolesContractPartner, emitvalue="", mapoptions="", readonly=R"!activetxn",)
                                    ),
                                    htmldiv(class="", col=0,
                                        select(R"pr['rev']['ref_partner']['value']", bgcolor="white", label="ref_partner sel", options=:partner_ids, readonly=R"!activetxn",)
                                    )
                                ])
                            )
                        ]), hr(),
                        expansionitem(label="product items", class="q-mt-md q-mr-sm bg-deep-purple-8 text-white", [
                            select(:new_product_reference, bgcolor="white", label="referenced product", options=:product_ids, emitvalue="", mapoptions="", var"v-if"="activetxn && cs['product_items'].length==0",),
                            htmldiv(var"v-for"="role in Object.keys(productpartnerroles)",
                                htmldiv(class="row", [
                                    htmldiv(class="", col=0,
                                        "{{rolesTariffItemPartner[role-1]['label']}}"
                                    ),
                                    htmldiv(class="", col=0,
                                        select(R"productpartnerroles[role]", bgcolor="white", options=:partner_ids, emitvalue="", mapoptions="",)
                                    )
                                ])
                            ),
                            btn("add", var"v-on:click"="command='add productitem'", var"v-if"="Object.values(productpartnerroles).length >0 && !Object.values(productpartnerroles).includes(0)",),
                            htmldiv(var"v-for"="(pi,piidx) in cs['product_items']", class="q-pa-md", [
                                htmldiv(class="q-pa-md",
                                    btn("delete", var"v-on:click"="selected_productitem_idx=piidx", var"v-if"="activetxn",)
                                ),
                                htmldiv(class="row", [
                                    htmldiv(class="", col=0,
                                        textfield("product", R"product_names[pi['revision']['ref_product']['value']]", bgcolor="white", readonly=R"!activetxn",)
                                    ),
                                    htmldiv(class="", col=0,
                                        textfield("product id", R"pi['revision']['ref_product']['value']", bgcolor="white", readonly=R"!activetxn",)
                                    ),
                                    htmldiv(class="", col=0,
                                        textfield("description", R"pi['revision']['description']", bgcolor="white", readonly=R"!activetxn",)
                                    )
                                ]),
                                hr(),
                                expansionitem(label="tariff items",
                                    StippleUI.list(class="q-mt-md q-mr-sm bg-purple text-white",
                                        htmldiv(var"v-for"="(ti,tiidx) in pi['tariff_items']", class="q-pa-md", [
                                            htmldiv(class="row", [
                                                htmldiv(class="", col=0, [
                                                    btn("select", flat="", var"v-on:click"="selected_productitem_idx=piidx; selected_tariffitem_idx=tiidx;tariffitem_selections[piidx+1][tiidx+1]=true", color="primary", var"v-if"="!tariffitem_selections[piidx+1][tiidx+1]",),
                                                    btn("calculator", flat="", var"v-on:click"="opendialogue=true; selected_productitem_idx=piidx; selected_tariffitem_idx=tiidx", color="primary", var"v-else"="",)
                                                ]),
                                                htmldiv(class="", col=0,
                                                    textfield("description", R"ti['tariff_ref']['rev']['description']", bgcolor="white", readonly=R"!activetxn",)
                                                )
                                            ]),
                                            htmldiv(class="row", [
                                                htmldiv(class="", col=0,
                                                    textfield("ref_tariff", R"ti['tariff_ref']['rev']['ref_tariff']['value']", bgcolor="white", readonly=R"true",)
                                                ),
                                                htmldiv(var"v-for"="(def, name) in ti['contract_attributes']", [
                                                    htmldiv(class="", var"v-if"="def['type']=='Int'", col=0,
                                                        textfield(:name, R"def['value']", bgcolor="white", type="Number", rules=R"[
                                                                   val => (val !== null && val !== '' && parseInt(val)!=NaN) &&  val.indexOf('.')<0 || 'Please type an integer'
                                                                   ]", step=R"1", readonly=R"!activetxn",)
                                                    ),
                                                    htmldiv(class="", var"v-else-if"="def['type']=='String'", col=0,
                                                        textfield(:name, R"def['value']", bgcolor="white", type="String", readonly=R"!activetxn",)
                                                    ),
                                                    htmldiv(class="", var"v-else-if"="def['type']=='Date'", col=0,
                                                        textfield(:name, R"def['value']", bgcolor="white", filled="", readonly=R"!activetxn", [
                                                            icon("event", class="cursor-pointer",
                                                                quasar(:popup_proxy, cover="", transitionshow="scale", transitionhide="scale",
                                                                    quasar(:date, bgcolor="white", title=:name, fieldname="def['value']", mask="YYYY-MM-DD",
                                                                        htmldiv(class="row items-center justify-end",
                                                                            btn("Close", vclosepopup="", color="primary", flat="",)
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        ])
                                                    )
                                                ])
                                            ]),
                                            expansionitem(label="tariff_item_partners",
                                                StippleUI.list(class="q-mt-md q-mr-sm bg-deep-purple-8 text-white",
                                                    htmldiv(var"v-for"="tipr in ti['partner_refs']", class="q-pa-md", [
                                                        htmldiv(class="row",
                                                            htmldiv(class="", col=0,
                                                                textfield("description", R"tipr['rev']['description']", bgcolor="white", readonly=R"!activetxn",)
                                                            )
                                                        ),
                                                        htmldiv(class="row", [
                                                            htmldiv(class="", col=0,
                                                                select(R"tipr['rev']['ref_role']['value']", label="ref_role", bgcolor="white", options=:rolesTariffItemPartner, emitvalue="", var"v-if"="activetxn",)
                                                            ),
                                                            htmldiv(class="", col=0,
                                                                textfield("ref_role", R"rolesTariffItemPartner[tipr['rev']['ref_role']['value']-1]['label']", bgcolor="white", readonly=R"true",)
                                                            ),
                                                            htmldiv(class="", col=0,
                                                                textfield("ref_partner", R"tipr['rev']['ref_partner']['value']", bgcolor="white", readonly=R"true",)
                                                            )
                                                        ])
                                                    ])
                                                )
                                            )
                                        ])
                                    )
                                )
                            ])
                        ])])
                ])
            ])
        ]),
    ])
)

@app MF begin
    @in gpanel::String = "panel"
    # workflow
    @in command::String = ""
    @in tab::String = ""
    @in tab_m::String = ""
    @out current_workflow::Workflow = Workflow()
    @out activetxn::Bool = false
    @out txn_time::ZonedDateTime = now(tz"UTC")
    @in newreftime::String = ""
    @out ref_time::ZonedDateTime = now(tz"UTC")
    #roles
    @out rolesContractPartner::Vector{Dict{String,Any}} = []
    @in productpartnerroles::Dict{Integer,Integer} = Dict()
    @out rolesTariffItem::Vector{Dict{String,Any}} = []
    @out rolesTariffItemPartner::Vector{Dict{String,Any}} = []
    # contract
    @out contracts::Vector{Contract} = []
    @out contract_ids::Dict{Int64,Int64} = Dict{Int64,Int64}()
    @out current_contract::Contract = Contract()
    @in selected_contract_idx::Integer = -1
    @in cs::Dict{String,Any} = Dict{String,Any}("loaded" => "false")
    @out partner_ids::Vector{Dict{String,Any}} = []
    @out product_ids::Vector{Dict{String,Any}} = []
    @in prompt_new_txn::Bool = false
    @in prompt_create_contract::Bool = false
    @in tariffitem_selections::Dict{Integer,Dict{Integer,Bool}} = Dict()

    # contract partners
    @in show_contract_partners::Bool = false
    @in new_contract_partner_role::Integer = 0
    @in new_contract_partner::Integer = 0
    @in selected_contractpartner_idx::Integer = -1

    # product
    @out product_names::Dict{Integer,String} = Dict()
    #product items
    @in show_product_items::Bool = false
    @in new_product_reference::Integer = 0

    @out partnerrolemap::Dict{Integer,PartnerSection} = Dict()
    @out tpidrolemap::Dict{Integer,Integer} = Dict{Integer,Integer}()


    @onchange isready begin
        rolesContractPartner = load_role(ContractPartnerRole)
        rolesTariffItem = load_role(TariffItemRole)
        rolesTariffItemPartner = load_role(TariffItemPartnerRole)
        @show rolesContractPartner
        @show rolesTariffItem
        @show rolesTariffItemPartner
        cs["loaded"] = "false"

        @push
        @show partner_ids
        @show product_ids
        @show "App is loaded"
        @show "ready"
        tab = "contracts"
    end

    @onchange command begin
        @show command
    end

    @onchange tab begin
        @show "tab changed"
        @show tab

        if tab == "contracts"
            current_contract = Contract()
            contracts = get_contracts()
            let df = SearchLight.query("select distinct c.id, w.is_committed from contracts c join histories h on c.ref_history = h.id join workflows w on w.ref_history = h.id ")
                for p in Pair.(df.id, df.is_committed)
                    println(p)
                    if haskey(contract_ids, p.first)
                        if p.second == 0
                            contract_ids[p.first] = 0
                        end
                    else
                        contract_ids[p.first] = p.second
                    end
                end
            end
        end

        if (tab == "csection")
            @show tab
        end
    end

    @onchange selected_contract_idx begin
        if (selected_contract_idx >= 0)
            @show "selected_contract_idx"
            @show selected_contract_idx
            @info "enter selected_contract_idx"
            try
                current_contract = contracts[selected_contract_idx+1]
                activetxn = length(find(ValidityInterval, SQLWhereExpression("ref_history=? and is_committed=0", current_contract.ref_history))) == 1

                @show current_contract
                @show activetxn

                if activetxn
                    current_workflow = find(Workflow, SQLWhereExpression("ref_history=? and is_committed=0", current_contract.ref_history))[1]
                    ref_time = current_workflow.tsw_validfrom
                    histo = map(treeview, history_forest(current_contract.ref_history.value).shadowed)
                    cs = JSON.parse(serialize(csection(current_contract.id.value, now(tz"UTC"), ref_time, activetxn ? 1 : 0)))
                    cs["loaded"] = "true"
                    new_product_reference = 0
                else
                    ref_time = MaxDate - Day(1)
                    histo = map(treeview, history_forest(current_contract.ref_history.value).shadowed)
                    cs = JSON.parse(serialize(csection(current_contract.id.value, now(tz"UTC"), ref_time, activetxn ? 1 : 0)))
                    cs["loaded"] = "true"
                end
                for pi in 1:length(cs["product_items"])
                    tariffitem_selections[pi] = Dict()
                    for ti in 1:length(cs["product_items"][pi]["tariff_items"])
                        tariffitem_selections[pi][ti] = false
                    end
                end
                selected_tariffitem_idx = -1
                selected_productitem_idx = -1
                @push
                @show current_workflow
                cs_persisted = deepcopy(cs)
                @info "cs==cs_persisted?"
                @show cs == cs_persisted
                @show cs
                @show cs_persisted
                push!(CS_UNDO, cs_persisted)

                tab = "csection"
                selected_contract_idx = -1
                @info "contract loaded"
                @show cs["loaded"]
            catch err
                println("wassis shief gegangen ")
                @error "ERROR: " exception = (err, catch_backtrace())
            end
        end
    end


    route("/") do
        global model
        model = @init MF
        page(model, ui, title="My Title",) |> html
    end
end
end