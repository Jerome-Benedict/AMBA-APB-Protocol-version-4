class apb_agent_config extends uvm_object;
  `uvm_object_utils(apb_agent_config)

  // ---------------- ACTIVE / PASSIVE ---------------- //
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // ---------------- COMPONENT ENABLE ---------------- //
  bit has_driver = 1;
  bit has_sequencer = 1;
  bit has_monitor = 1;
  
  virtual apb_if vif;

  // ---------------- PROTOCOL OPTIONS ---------------- //
  bit enable_checks = 1;
  bit enable_coverage = 1;

  // ---------------- TIMING CONTROL ---------------- //
  int unsigned max_wait_cycles = 10;

  // ---------------- DEBUG ---------------- //
  bit enable_print = 0;

  // ---------------- CONSTRUCTOR ---------------- //
  function new(string name="apb_agent_config");
    super.new(name);
  endfunction

endclass : apb_agent_config
