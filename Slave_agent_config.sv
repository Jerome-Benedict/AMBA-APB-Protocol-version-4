class apb_slave_config extends apb_agent_config;
  `uvm_object_utils(apb_slave_config)
  
  bit [31:0] start_addr;
  bit [31:0] end_addr;

  function new(string name="apb_slave_config");
    super.new(name);
    is_active = UVM_PASSIVE;
    has_driver = 0;
    has_sequencer = 0;
    has_monitor = 1;
  endfunction : new

endclass : apb_slave_config
