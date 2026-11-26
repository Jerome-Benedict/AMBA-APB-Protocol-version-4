class apb_env_config extends uvm_object;
  `uvm_object_utils(apb_env_config)
  
  int num_master_agents = 1;
  int num_slave_agents  = 0;
  int num_slaves;

  bit enable_scoreboard = 1;
  bit enable_coverage   = 1;

  apb_agent_config master_cfg;
  apb_slave_config slave_cfg[$];

  function new(string name = "apb_env_config");
    super.new(name);
  endfunction

endclass
