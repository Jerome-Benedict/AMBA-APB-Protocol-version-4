class apb_master_agent extends uvm_agent;
  `uvm_component_utils(apb_master_agent)

  apb_master_driver drv;
  apb_master_sequencer seqr;
  apb_master_monitor mon;
  apb_agent_config cfg;

  function new(string name="apb_master_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(apb_agent_config)::get(this, "", "m_cfg", cfg))
      `uvm_fatal("AGENT", "m_cfg not found")

    if (cfg.has_monitor) begin
      mon = apb_master_monitor::type_id::create("mon", this);
      
      uvm_config_db#(apb_agent_config)::set(this, "mon", "cfg", cfg);
    end

    if (cfg.is_active == UVM_ACTIVE) begin
      if (cfg.has_driver) begin
        drv = apb_master_driver::type_id::create("drv", this);
        uvm_config_db#(apb_agent_config)::set(this, "drv", "cfg", cfg);
      end
      if (cfg.has_sequencer) begin
        seqr = apb_master_sequencer::type_id::create("seqr", this);
        uvm_config_db#(apb_agent_config)::set(this, "seqr", "cfg", cfg);
      end
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE)
      if (cfg.has_driver && cfg.has_sequencer)
        drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
