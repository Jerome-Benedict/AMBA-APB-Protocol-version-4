class apb_slave_agent extends uvm_agent;
  `uvm_component_utils(apb_slave_agent)

  apb_slave_monitor mon;
  apb_slave_config  cfg;

  function new(string name="apb_slave_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    int sid;
    super.build_phase(phase);
    
    if (!uvm_config_db#(apb_slave_config)::get(this, "", "s_cfg", cfg))
      `uvm_fatal("SLV_AGENT", "s_cfg not found")

    cfg.is_active = UVM_PASSIVE;

    if (cfg.has_monitor) begin
      mon = apb_slave_monitor::type_id::create("mon", this);
      uvm_config_db#(apb_slave_config)::set(this, "mon", "cfg", cfg);
      
      if (!uvm_config_db#(int)::get(this, "", "slave_id", sid))
        `uvm_fatal("SLV_AGENT", "slave_id not found")
      uvm_config_db#(int)::set(this, "mon", "slave_id", sid);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass
