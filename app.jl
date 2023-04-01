module App

using GenieFramework
using JSON, DataStructures, Dates, SearchLight, TimeZones
using LifeInsuranceContracts
import LifeInsuranceContracts: tostruct, find, SQLWhereExpression,
  connect, get_contracts, get_partners, get_ids, get_products, serialize, deserialize, create_component!, update_component!, update_entity!, commit_workflow!, rollback_workflow!, persistModelStateContract,
  ContractPartnerRole, TariffItemRole, TariffItemPartnerRole,
  Contract, Partner, Product, Tariff, Workflow,
  ContractSection, PartnerSection, ProductItemSection, TariffItemSection, ProductSection, TariffSection,
  csection, psection, pisection, prsection, tsection,
  get_contracts, get_partners, get_products, history_forest,
  get_tariff_interface, persist_tariffs, compareModelStateContract, compareRevisions, treeview, get_node_by_label, load_role

@genietools

include("treeedit.jl")

CS_UNDO = Stack{Dict{String,Any}}()

@handlers begin
  @out activetxn::Bool = false
  @in command::String = ""
  @in prompt_new_txn::Bool = false
  @in prompt_create_contract::Bool = false
  @out contracts::Vector{Contract} = []
  @out contract_ids::Dict{Int64,Int64} = Dict{Int64,Int64}()
  @out current_contract::Contract = Contract()
  @in selected_contract_idx::Integer = -1
  @out current_workflow::Workflow = Workflow()
  @out partners::Vector{Partner} = []
  @out partner_ids::Vector{Dict{String,Any}} = []
  @out current_partner::Partner = Partner()
  @in selected_partner_idx::Integer = -1
  @out products::Vector{Product} = []
  @out product_ids::Vector{Dict{String,Any}} = []
  @out current_product::Product = Product()
  @in selected_product_idx::Integer = -1
  @in new_contract_partner_role::Integer = 0
  @in new_contract_partner::Integer = 0
  @in selected_contractpartner_idx::Integer = -1
  @in selected_productitem_idx::Integer = -1
  @in selected_tariffitem_idx::Integer = -1
  @in selected_tariffitem::Dict{Integer,Dict{Integer,Bool}} = Dict()
  @in new_tariffitem_partner::Dict{Integer,Integer} = Dict()
  @in selected_version::String = ""
  @out current_version::Integer = 0
  @out txn_time::ZonedDateTime = now(tz"UTC")
  @in newreftime::String = ""
  @out ref_time::ZonedDateTime = now(tz"UTC")
  @out histo::Vector{Dict{String,Any}} = Dict{String,Any}[]
  @in cs::Dict{String,Any} = Dict{String,Any}("loaded" => "false")
  @out cs_persisted = Dict{String,Any}()
  @out ps::Dict{String,Any} = Dict{String,Any}("loaded" => "false")
  @out prs::Dict{String,Any} = Dict{String,Any}("loaded" => "false")
  @out prs0::ProductSection = ProductSection()

  @in selected_product_part_idx::Integer = 0
  @in tab::String = "csection"
  @in leftDrawerOpen::Bool = false
  @in show_contract_partners::Bool = false
  @in show_product_items::Bool = false
  @in new_product_reference::Integer = 0
  @in productpartnerroles::Dict{Integer,Integer} = Dict()
  @out partnerrolemap::Dict{Integer,PartnerSection} = Dict()
  @out tpidrolemap::Dict{Integer,Integer} = Dict{Integer,Integer}()
  @in show_tariff_item_partners::Bool = false
  @in show_tariff_items::Bool = false
  @out d::Dict{String,Any} = Dict()
  @in tree::Vector{Dict{Symbol,Any}} = []
  @out rolesContractPartner::Vector{Dict{String,Any}} = []
  @out rolesTariffItem::Vector{Dict{String,Any}} = []
  @out rolesTariffItemPartner::Vector{Dict{String,Any}} = []
  # tariff calculations
  @in tariffcalculation::Dict{String,Any} = get_tariff_interface(Val(0)).calls
  @in calculate::Bool = false
  @out validated::Bool = false
  @in opendialogue::Bool = false
  @out tariff_interface_id::Integer = 0

  @onchange isready begin
    connect()
    rolesContractPartner = load_role(ContractPartnerRole)
    rolesTariffItem = load_role(TariffItemRole)
    rolesTariffItemPartner = load_role(TariffItemPartnerRole)
    @show rolesContractPartner
    @show rolesTariffItem
    @show rolesTariffItemPartner
    cs["loaded"] = "false"
    prs = Dict{String,Any}("loaded" => "false")
    ps = Dict{String,Any}("loaded" => "false")
    partners = get_partners()

    push!(partner_ids, Dict("value" => 0, "label" => "nobody"))
    partner_ids = get_ids(partners)
    for p in get_products()
      rev = prsection(p.id.value, now(tz"UTC"), now(tz"UTC"), 0).revision
      push!(product_ids, Dict("label" => rev.description, "value" => rev.id.value))
    end
    push!(product_ids, Dict("label" => "none", "value" => 0))
    try
      @info "vor tariffcalculation tariff_interface_id"
      @push
      @show partner_ids
      @show product_ids
      @show "App is loaded"
      @show tariffcalculation
      # calls = get_tariff_interface(Val(2)).calls
      # d = deepcopy(calls)
      # tree = [dict_tree(calls)]
      # @show tree
      tab = "contracts"
    catch err
      println("wassis shief gegangen ")
      @error "ERROR: " exception = (err, catch_backtrace())
    end
  end

  @onchange cs begin
    @info "cs changed"
  end
  """
  @onchange prompt_new_txn 
  starting a new txn on the current contract
  """

  @onchange prompt_new_txn begin
    @info "prompt_new_txn pressed"
    @show prompt_new_txn
    if !prompt_new_txn
      @show newreftime
      @show ref_time
      if newreftime == ""
        @info "cancelled"
      else
        n = replace(newreftime, "/" => "-")
        ref_time = ZonedDateTime(DateTime(n), tz"UTC")
        current_workflow = Workflow(
          type_of_entity="Contract",
          tsw_validfrom=ref_time,
          ref_history=current_contract.ref_history
        )
        txntime = current_workflow.tsdb_validfrom
        update_entity!(current_workflow)
        activetxn = true

        cs = JSON.parse(serialize(csection(current_contract.id.value, now(tz"UTC"), ref_time, activetxn ? 1 : 0)))
        cs["loaded"] = "true"
        cs_persisted = deepcopy(cs)

        @info "cs==cs_persisted?"
        @show cs == cs_persisted
        @show cs
        @show cs_persisted
        push!(CS_UNDO, cs_persisted)
      end
    else
      @info "öffnen"
    end
  end

  """
  @onchange prompt_create_contract 
  creating a new contract whereby a txn on the new  contract is started
  """

  @onchange prompt_create_contract begin
    @info "prompt_create_contract pressed"
    @show prompt_create_contract
    if !prompt_create_contract
      activetxn = true
      w1 = Workflow(
        type_of_entity="Contract",
        tsw_validfrom=ref_time,
        tsdb_validfrom=now(tz"UTC")
      )
      create_entity!(w1)
      c = Contract()
      cr = ContractRevision(description="contract creation properties")
      @info "before create component"
      create_component!(c, cr, w1)
      @info "after create component"
      current_workflow = w1
      current_contract = c

      histo = map(treeview, history_forest(current_contract.ref_history.value).shadowed)
      cs = JSON.parse(serialize(csection(current_contract.id.value, now(tz"UTC"), ref_time, 1)))
      cs["loaded"] = "true"
      cs_persisted = deepcopy(cs)
      @info "cs==cs_persisted?"
      @show cs == cs_persisted
      push!(CS_UNDO, cs_persisted)
      @push
    end
  end

  """
  @onchange new_product_reference
  select a product reference for the first product item productpartnerroles is initialized for the selected product 
  """

  @onchange new_product_reference begin
    @show new_product_reference
    if new_product_reference > 0
      @show current_workflow
      prs0 = prsection(new_product_reference, now(tz"UTC"), ref_time)
      @show prs0
      productpartnerroles = Dict()

      map(prs0.parts) do pt
        for r in pt.ref.partner_roles
          productpartnerroles[r.ref_role.value] = 0
        end
      end
      @show productpartnerroles
      @push
    end

  end

  @onchange productpartnerroles begin
    @info "productpartnerroles"
    @show productpartnerroles
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
          selected_tariffitem[pi] = Dict()
          for ti in 1:length(cs["product_items"][pi])
            selected_tariffitem[pi][ti] = false
          end
        end
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
        @show cs_persisted
      catch err
        println("wassis shief gegangen ")
        @error "ERROR: " exception = (err, catch_backtrace())
      end
    end
  end

  @onchange selected_partner_idx begin
    @show selected_partner_idx
    @info "selected_partner_idx"
    if (selected_partner_idx >= 0)
      @show selected_partner_idx
      @info "enter selected_partner_idx"
      try
        current_partner = partners[selected_partner_idx+1]
        # histo = map(treeview, history_forest(current_contract.ref_history.value).shadowed)
        ps = JSON.parse(serialize(psection(current_partner.id.value, now(tz"UTC"), now(tz"UTC"), activetxn ? 1 : 0)))
        ps["loaded"] = "true"
        selected_partner_idx = -1
        ps["loaded"] = "true"
        @show ps["loaded"]
        tab = "partner"
        @show tab
      catch err
        println("wassis shief gegangen ")
        @error "ERROR: " exception = (err, catch_backtrace())
      end
    end
  end
  @onchange selected_product_idx begin
    @show selected_product_idx
    @info "selected_product_idx"
    if (selected_product_idx >= 0)
      @show selected_product_idx
      @info "enter selected_product_idx"
      try
        current_product = products[selected_product_idx+1]
        # histo = map(treeview, history_forest(current_contract.ref_history.value).shadowed)
        prs = JSON.parse(serialize(prsection(current_product.id.value, now(tz"UTC"), now(tz"UTC"), activetxn ? 1 : 0)))
        selected_product_idx = -1
        prs["loaded"] = "true"
        @show prs["loaded"]
        tab = "product"
        @show tab
      catch err
        println("wassis shief gegangen ")
        @error "ERROR: " exception = (err, catch_backtrace())
      end
    end
  end

  @onchange selected_contractpartner_idx begin
    if selected_contractpartner_idx != -1
      @show selected_contractpartner_idx
    end
  end

  @onchange selected_productitem_idx begin
    if selected_productitem_idx != -1
      @show selected_productitem_idx
    end
  end

  @onchange selected_tariffitem_idx begin
    if selected_tariffitem_idx != -1
      @info "gleich tariff_interface_id=@="
      @show selected_tariffitem_idx
      for p in keys(selected_tariffitem)
        for t in keys(selected_tariffitem[p])
          selected_tariffitem[p][t] = false
        end
      end
      @info "nach reset"
      @show selected_tariffitem
      selected_tariffitem[selected_productitem_idx+1][selected_tariffitem_idx+1] = true
      @show selected_tariffitem
      @info "setting tariff_interface_id"
      tariff_interface_id = cs["product_items"][selected_productitem_idx+1]["tariff_items"][selected_tariffitem_idx+1]["tariff_ref"]["ref"]["revision"]["interface_id"]
      @show tariff_interface_id
      tariffcalculation = get_tariff_interface(Val(tariff_interface_id)).calls
      @show tariffcalculation
      @push
      #@show keys(tariffcalculation)
      #for_each(keys(tariffcalculation)) do param
      #  @show param
      #end
    end
  end

  @onchange command begin
    if command != ""

      try
        @show command
        """
        command clear contract
        """

        if command == "clear contract"
          current_contract = Contract()
          cs = Dict{String,Any}("loaded" => "false")
        end
        """
        command add productitem
        """
        if command == "add productitem"
          @show command
          @show productpartnerroles
          @show values(productpartnerroles)
          @show 0 in values(productpartnerroles)
          partnerrolemap::Dict{Integer,PartnerSection} = Dict()
          for key in keys(productpartnerroles)
            partnerrolemap[key] = psection(productpartnerroles[key], now(tz"UTC"), ref_time)
          end
          @show partnerrolemap
          @info "before instantiation"
          pis = instantiate_product(prs0, partnerrolemap)
          @info "productitem created"
          pisj = JSON.parse(serialize(pis))
          @show pisj
          cs["product_items"] = [pisj]
          @show cs["product_items"]
          @push
          command = ""
        end
        if command == "add contractpartner"
          @show command
          @show cs["partner_refs"]


          cprj = JSON.parse(serialize(ContractPartnerReference(
            rev=ContractPartnerRefRevision(ref_role=DbId(new_contract_partner_role), ref_partner=DbId(new_contract_partner)),
            ref=PartnerSection())))
          new_contract_partner_role = 0
          new_contract_partner = 0
          append!(cs["partner_refs"], [cprj])
          @show cs["partner_refs"]
          @info "anzahl prefs= "
          @info length(cs["partner_refs"])
          @push
          command = ""
        end

        if command == "start transaction"
          activetxn = true
          w1 = Workflow(
            type_of_entity="Contract",
            ref_history=current_contract.ref_history,
            tsw_validfrom=ref_time,
          )
          update_entity!(w1)
          current_workflow = w1
          cs = JSON.parse(serialize(csection(current_contract.id.value, now(tz"UTC"), ref_time, activetxn ? 1 : 0)))
          cs["loaded"] = "true"
          @push
          @show command
          command = ""

        end

        if startswith(command, "delete_contract_partner")

          @show command
          @show first(CS_UNDO)["partner_refs"]
          idx = parse(Int64, chopprefix(command, "delete_contract_partner:"))

          @show cs["partner_refs"][idx+1]["rev"]
          if isnothing(cs["partner_refs"][idx+1]["rev"]["id"]["value"])
            deleteat!(cs["partner_refs"], idx + 1)
            @info "after delete new cp"
          else
            cs["partner_refs"][idx+1]["rev"]["ref_invalidfrom"]["value"] = current_workflow.ref_version
            @show cs["partner_refs"][idx+1]["rev"]
            @info "after delete persisted cp"
          end
          @push
        end

        if command == "pop"
          @info "before pop"
          @show first(CS_UNDO)["partner_refs"]
          cs = pop!(CS_UNDO)
          @push
          @info "after pop"
          @show cs["partner_refs"]
        end

        if command == "push"
          push!(CS_UNDO, deepcopy(cs))
          @show first(CS_UNDO)["partner_refs"]
        end
        if command == "compare"
          @show command
          @show cs_persisted
          deltas = compareModelStateContract(cs_persisted, cs, current_workflow)
          @info "showing deltas"
          @show deltas

        end

        if command == "persist"
          @show command
          @show cs_persisted
          persistModelStateContract(cs_persisted, cs, current_workflow, current_contract)

          cs = JSON.parse(serialize(csection(current_contract.id.value, txn_time, ref_time, 1)))
          cs["loaded"] = "true"
          @push
        end
        if command == "commit"
          @show command
          @show current_workflow
          commit_workflow!(current_workflow)
          activetxn = 0
          current_workflow = Workflow()
        end
        if command == "rollback"
          @show command
          @show current_workflow

          rollback_workflow!(current_workflow)
          activetxn = 0
          command = "clear contract"
        end
        command = ""
      catch err
        println("wassis shief gegangen ")

        @error "ERROR: " exception = (err, catch_backtrace())
        command = ""
      end
    end
  end

  @onchange selected_version begin
    @info "version handler"
    @show selected_version
    if selected_version != ""
      @show tab
      try
        node = fn(histo, selected_version)
        @info "node"
        @show node
        activetxn = (node["interval"]["is_committed"] == 0 ? true : false)
        txn_time = node["interval"]["tsdb_validfrom"]
        ref_time = node["interval"]["tsworld_validfrom"]
        current_version = parse(Int, selected_version)
        @show activetxn
        @show txn_time
        @show ref_time
        @show current_version
        @info "vor csection"
        cs = JSON.parse(serialize(csection(current_contract.id.value, txn_time, ref_time, activetxn ? 1 : 0)))
        cs["loaded"] = "true"
        @info "vor tab "
        tab = "csection"
      catch err
        println("wassis shief gegangen ")

        @error "ERROR: " exception = (err, catch_backtrace())
      end
    end
  end

  @onchange opendialogue begin
    @info "opendialogue"
    @show selected_tariffitem
    @show tariff_interface_id
    @show get_tariff_interface(Val(tariff_interface_id)).calls
  end

  @onchange tariffcalculation begin
    if haskey(tariffcalculation, "calculation_target")
      let fn = tariffcalculation["calculation_target"]["selected"]
        if fn != "none"
          println(fn)

          for p in tariffcalculation["calculation_target"][fn]
            @show p.first
            @show p.second["value"]
          end
          validated = mapreduce(def -> !(isnothing(def.second["value"]) || def.second["value"] == ""), &, tariffcalculation["calculation_target"][fn])
          @show validated
        end
      end
    end
  end

  @onchange calculate begin
    if calculate
      calculate = false
      @info "calculating"
      try
        @show tariff_interface_id
        calculator = get_tariff_interface(Val(tariff_interface_id)).calculator
        @show selected_productitem_idx
        @show selected_tariffitem_idx
        ti = tostruct(TariffItemSection, cs["product_items"][selected_productitem_idx+1]["tariff_items"][selected_tariffitem_idx+1])
        calculator(Val(tariff_interface_id), ti, tariffcalculation)
        @push
      catch err
        @info("Exception calculating ")

        @error "ERROR: " exception = (err, catch_backtrace())

      end
    end
  end

  @onchange tab begin

    @show tab

    if tab == "contracts"
      current_contract = Contract()
      contracts = get_contracts()
      let df = SearchLight.query("select distinct c.id, w.is_committed from contracts c join histories h on c.ref_history = h.id join workflows w on w.ref_history = h.id ")
        contract_ids = Dict(Pair.(df.id, df.is_committed))
      end
      @show contract_ids
      @info "contractsModel pushed"
    end

    if (tab == "partners")
      partners = get_partners()
      @info "read partners"
    end
    if (tab == "products")
      @info "products"
      products = get_products()
      @show products
      @push
      @info "read products"
    end
    if (tab == "csection")
      @show tab
    end
    if (tab == "product")
      @show tab
    end
    if (tab == "partner")
      @show tab
    end
    @info "leave tab handler"
  end
end

@page("/", "app.jl.html")

end