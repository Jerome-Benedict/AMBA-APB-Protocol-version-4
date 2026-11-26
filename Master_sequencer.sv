class apb_master_sequencer extends uvm_sequencer #(apb_sequence_item);
  `uvm_component_utils(apb_master_sequencer)
  virtual apb_if vif;
  
  apb_agent_config cfg;

  // ---------------- Constructor ---------------- //
  function new(string name="apb_master_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  // ---------------- Build Phase ---------------- //
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(apb_agent_config)::get(this, "", "cfg", cfg)) begin
      `uvm_fatal("SEQ", "apb_agent_config not found")
    end
    vif = cfg.vif;
    
    if(vif == null) begin
      `uvm_fatal("SEQ", "Virtual interface is NULL")
    end
    
  endfunction

  // ---------------- Run Phase ---------------- //
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    `uvm_info("SEQ", "APB Master Sequencer Started", UVM_LOW)
    
    forever begin
      @(posedge vif.PCLK);
      
      if(vif.PSEL && vif.PENABLE) begin
        `uvm_info("SEQ", $sformatf("Active Transfer: ADDR=%0h WRITE=%0b", vif.PADDR, vif.PWRITE), UVM_DEBUG)
      end
    end
  endtask : run_phase

endclass : apb_master_sequencer
