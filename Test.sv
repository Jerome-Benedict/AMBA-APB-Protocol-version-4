class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)

  apb_env env;
  apb_env_config env_cfg;

  apb_agent_config m_cfg;
  apb_slave_config s0_cfg, s1_cfg;

  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="apb_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------Build Phase---------------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_cfg = apb_env_config::type_id::create("env_cfg");
    m_cfg = apb_agent_config::type_id::create("m_cfg");
    s0_cfg = apb_slave_config::type_id::create("s0_cfg");
    s1_cfg = apb_slave_config::type_id::create("s1_cfg");

    m_cfg.is_active = UVM_ACTIVE;
    m_cfg.has_driver = 1;
    m_cfg.has_sequencer= 1;
    m_cfg.has_monitor = 1;

    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",m_cfg.vif))
      `uvm_fatal("TEST","VIF not set for MASTER")

    s0_cfg.is_active = UVM_PASSIVE;
    s0_cfg.has_monitor= 1;
    s0_cfg.start_addr = 32'h0000_0000;
    s0_cfg.end_addr = 32'h0000_0FFF;
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",s0_cfg.vif))
      `uvm_fatal("TEST","VIF not set for SLAVE0")

    s1_cfg.is_active = UVM_PASSIVE;
    s1_cfg.has_monitor = 1;
    s1_cfg.start_addr = 32'h0001_0000;
    s1_cfg.end_addr = 32'h0001_0FFF;
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",s1_cfg.vif))
      `uvm_fatal("TEST","VIF not set for SLAVE1")

    env_cfg.master_cfg = m_cfg;
    env_cfg.slave_cfg.push_back(s0_cfg);
    env_cfg.slave_cfg.push_back(s1_cfg);
    env_cfg.enable_scoreboard = 1;
    env_cfg.enable_coverage = 1;
    env_cfg.num_slaves = 2;

    uvm_config_db#(apb_env_config)::set(this,"*","env_cfg",env_cfg);
    env = apb_env::type_id::create("env",this);
  endfunction : build_phase

  //---------------------------------------End of Elaboration Phase---------------------------------------//
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase
  
  //---------------------------------------Reset Task---------------------------------------//
  protected task apply_reset(int reset_cycles=5, int wait_after=3);
    env_cfg.master_cfg.vif.PRESETn = 0;
    
    repeat(reset_cycles) @(posedge env_cfg.master_cfg.vif.PCLK);
    env_cfg.master_cfg.vif.PRESETn = 1;
    repeat(wait_after) @(posedge env_cfg.master_cfg.vif.PCLK);
    
    if (env != null && env.sb != null)
      env.sb.clear_ref_mem();
    `uvm_info("TEST", "Reset released + ref_mem cleared", UVM_LOW)
  endtask : apply_reset

endclass : apb_test


//-----------------------------CLass Extends for testcases------------------//

//---------------------------Testcase 1--------------------------------//
class TC_APB_WRITE_SINGLE_test extends apb_test;
  `uvm_component_utils(TC_APB_WRITE_SINGLE_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_WRITE_SINGLE_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_WRITE_SINGLE seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_WRITE_SINGLE::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if(env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_WRITE_SINGLE: FAIL - unexpected scoreboard failures")
      
    else
      `uvm_info("TC_CHECK","TC_APB_WRITE_SINGLE: PASS",UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_WRITE_SINGLE_test

//---------------------------Testcase 2--------------------------------//
class TC_APB_READ_SINGLE_test extends apb_test;
  `uvm_component_utils(TC_APB_READ_SINGLE_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_READ_SINGLE_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_READ_SINGLE seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_READ_SINGLE::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if(env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_READ_SINGLE: FAIL")
      
    else
      `uvm_info("TC_CHECK","TC_APB_READ_SINGLE: PASS - unwritten read returned 0x0",UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_READ_SINGLE_test

//---------------------------Testcase 3--------------------------------//

//---------------------------Testcase 4--------------------------------//
class TC_APB_WRITE_READ_DIFF_ADDR_test extends apb_test;
  `uvm_component_utils(TC_APB_WRITE_READ_DIFF_ADDR_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_WRITE_READ_DIFF_ADDR_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_WRITE_READ_DIFF_ADDR seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_WRITE_READ_DIFF_ADDR::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if(env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_WRITE_READ_DIFF_ADDR: FAIL - read-back mismatch")
      
    else
      `uvm_info("TC_CHECK","TC_APB_WRITE_READ_DIFF_ADDR: PASS",UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_WRITE_READ_DIFF_ADDR_test

//---------------------------Testcase 5--------------------------------//

class TC_APB_SLAVE0_ACCESS_test extends apb_test;
  `uvm_component_utils(TC_APB_SLAVE0_ACCESS_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_SLAVE0_ACCESS_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_SLAVE0_ACCESS seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_SLAVE0_ACCESS::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if(env.sb.fail_count != 0 || env.sb.warn_count != 0)
      `uvm_error("TC_CHECK","TC_APB_SLAVE0_ACCESS: FAIL - error or no slave response")
      
    else
      `uvm_info("TC_CHECK","TC_APB_SLAVE0_ACCESS: PASS",UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_SLAVE0_ACCESS_test

//---------------------------Testcase 6--------------------------------//

class TC_APB_SLAVE1_ACCESS_test extends apb_test;
  `uvm_component_utils(TC_APB_SLAVE1_ACCESS_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_SLAVE1_ACCESS_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_SLAVE1_ACCESS seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_SLAVE1_ACCESS::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if(env.sb.fail_count != 0 || env.sb.warn_count != 0)
      `uvm_error("TC_CHECK","TC_APB_SLAVE1_ACCESS: FAIL")
      
    else
      `uvm_info("TC_CHECK","TC_APB_SLAVE1_ACCESS: PASS",UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_SLAVE1_ACCESS_test

//---------------------------Testcase 7--------------------------------//

class TC_APB_MULTI_SLAVE_ACCESS_test extends apb_test;
  `uvm_component_utils(TC_APB_MULTI_SLAVE_ACCESS_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_MULTI_SLAVE_ACCESS_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_MULTI_SLAVE_ACCESS seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_MULTI_SLAVE_ACCESS::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if(env.sb.fail_count != 0 || env.sb.txn_count < 2)
      `uvm_error("TC_CHECK","TC_APB_MULTI_SLAVE_ACCESS: FAIL")
    else
      `uvm_info("TC_CHECK","TC_APB_MULTI_SLAVE_ACCESS: PASS",UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_MULTI_SLAVE_ACCESS_test

//---------------------------Testcase 8--------------------------------//

class TC_APB_INVALID_SLAVE_SELECT_test extends apb_test;
  `uvm_component_utils(TC_APB_INVALID_SLAVE_SELECT_test)

  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_INVALID_SLAVE_SELECT_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_INVALID_SLAVE_SELECT seq;
    phase.raise_objection(this);
    apply_reset();

    seq = TC_APB_INVALID_SLAVE_SELECT::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    #200;
    
    if(env.sb.txn_count < 1)
      `uvm_error("TC_CHECK", "TC_APB_INVALID_SLAVE_SELECT: FAIL - no transaction recorded")
    
    else if(env.sb.skip_count < 1)
      `uvm_error("TC_CHECK", "TC_APB_INVALID_SLAVE_SELECT: FAIL - error=1 not seen; done incorrectly fired instead")
      
    else if(env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", "TC_APB_INVALID_SLAVE_SELECT: FAIL - unexpected scoreboard data failure")
      
    else if(env_cfg.master_cfg.vif.done !== 1'b0)
      `uvm_error("TC_CHECK", "TC_APB_INVALID_SLAVE_SELECT: FAIL - done is still high after invalid access")

    else
      `uvm_info("TC_CHECK", $sformatf("TC_APB_INVALID_SLAVE_SELECT: PASS - invalid address produced error=1, done stayed low | txn=%0d skip=%0d fail=%0d", env.sb.txn_count, env.sb.skip_count, env.sb.fail_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase

endclass : TC_APB_INVALID_SLAVE_SELECT_test

//---------------------------Testcase 9--------------------------------//
class TC_APB_WRITE_WITH_STRB_ZERO_test extends apb_test;
  `uvm_component_utils(TC_APB_WRITE_WITH_STRB_ZERO_test)

  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_WRITE_WITH_STRB_ZERO_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_WRITE_WITH_STRB_ZERO seq;
    phase.raise_objection(this);
    apply_reset();

    seq = TC_APB_WRITE_WITH_STRB_ZERO::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    #200;
    
    if(env.sb.txn_count < 2)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_WITH_STRB_ZERO: FAIL - expected 2 transactions (write + readback), got fewer")
      
    else if(env.sb.skip_count < 1)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_WITH_STRB_ZERO: FAIL - error=1 not seen for STRB=0 write; check slave RTL")
      
    else if(env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_WITH_STRB_ZERO: FAIL - unexpected scoreboard data failure")
      
    else if(env.sb.pass_count != 0 && env.sb.warn_count < 1)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_WITH_STRB_ZERO: FAIL - ref model updated despite STRB=0; memory not protected")

    else
      `uvm_info("TC_CHECK", $sformatf("TC_APB_WRITE_WITH_STRB_ZERO: PASS - STRB=0 produced error=1, memory untouched | txn=%0d skip=%0d warn=%0d fail=%0d", env.sb.txn_count, env.sb.skip_count, env.sb.warn_count, env.sb.fail_count), UVM_NONE)

    phase.drop_objection(this);
  endtask : run_phase

endclass : TC_APB_WRITE_WITH_STRB_ZERO_test

//---------------------------Testcase 10--------------------------------//

class TC_APB_WRITE_WITH_STRB_PARTIAL_test extends apb_test;
  `uvm_component_utils(TC_APB_WRITE_WITH_STRB_PARTIAL_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_WRITE_WITH_STRB_PARTIAL_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase); 
    
    TC_APB_WRITE_WITH_STRB_PARTIAL seq;
    
    phase.raise_objection(this);
    apply_reset();
    
    seq = TC_APB_WRITE_WITH_STRB_PARTIAL::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", $sformatf("TC_APB_WRITE_WITH_STRB_PARTIAL: FAIL - %0d failures", env.sb.fail_count))
      
    else if (env.sb.txn_count < 5)
      `uvm_error("TC_CHECK", $sformatf("TC_APB_WRITE_WITH_STRB_PARTIAL: FAIL - expected 5 txns got %0d", env.sb.txn_count))
      
    else if (env.sb.pass_count < 5)
      `uvm_error("TC_CHECK", $sformatf("TC_APB_WRITE_WITH_STRB_PARTIAL: FAIL - expected 5 passes got %0d", env.sb.pass_count))
      
    else
      `uvm_info("TC_CHECK", $sformatf("TC_APB_WRITE_WITH_STRB_PARTIAL: PASS - txn=%0d pass=%0d fail=%0d", env.sb.txn_count, env.sb.pass_count, env.sb.fail_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_WRITE_WITH_STRB_PARTIAL_test

//---------------------------Testcase 11--------------------------------//

class TC_APB_WRITE_WITH_STRB_ALL_test extends apb_test;
  `uvm_component_utils(TC_APB_WRITE_WITH_STRB_ALL_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_WRITE_WITH_STRB_ALL_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    
    TC_APB_WRITE_WITH_STRB_ALL seq;
    
    phase.raise_objection(this);
    apply_reset();
    
    seq = TC_APB_WRITE_WITH_STRB_ALL::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_WITH_STRB_ALL: FAIL - scoreboard failure")
      
    else if (env.sb.skip_count > 0)
      `uvm_error("TC_CHECK",
        "TC_APB_WRITE_WITH_STRB_ALL: FAIL - unexpected PSLVERR for STRB=1111")
      
    else if (env.sb.pass_count < 1)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_WITH_STRB_ALL: FAIL - no pass recorded")
      
    else
      `uvm_info("TC_CHECK", $sformatf("TC_APB_WRITE_WITH_STRB_ALL: PASS - txn=%0d pass=%0d", env.sb.txn_count, env.sb.pass_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_WRITE_WITH_STRB_ALL_test

//---------------------------Testcase 12--------------------------------//

class TC_APB_WRITE_AFTER_RESET_test extends apb_test;
  `uvm_component_utils(TC_APB_WRITE_AFTER_RESET_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_WRITE_AFTER_RESET_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_WRITE_AFTER_RESET seq;
    
    phase.raise_objection(this);
    apply_reset();
    
    seq = TC_APB_WRITE_AFTER_RESET::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", "TC_APB_WRITE_AFTER_RESET: FAIL - failure after reset")
      
    else if (env.sb.txn_count < 1)
      `uvm_error("TC_CHECK","TC_APB_WRITE_AFTER_RESET: FAIL - no transaction recorded")
      
    else if (env_cfg.master_cfg.vif.PSEL !== 1'b0)
      `uvm_error("TC_CHECK",
        "TC_APB_WRITE_AFTER_RESET: FAIL - PSEL not deasserted after txn")
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_WRITE_AFTER_RESET: PASS - txn=%0d pass=%0d",env.sb.txn_count, env.sb.pass_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
 
endclass : TC_APB_WRITE_AFTER_RESET_test

//---------------------------Testcase 13--------------------------------//

class TC_APB_READ_AFTER_RESET_test extends apb_test;
  `uvm_component_utils(TC_APB_READ_AFTER_RESET_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_READ_AFTER_RESET_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    
    TC_APB_READ_AFTER_RESET seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_READ_AFTER_RESET::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_READ_AFTER_RESET: FAIL - unexpected data mismatch")
      
    else if (env.sb.txn_count < 1)
      `uvm_error("TC_CHECK","TC_APB_READ_AFTER_RESET: FAIL - no transaction recorded")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_READ_AFTER_RESET: PASS - post-reset read OK | txn=%0d warn=%0d",env.sb.txn_count, env.sb.warn_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_READ_AFTER_RESET_test

//---------------------------Testcase 14--------------------------------//

class TC_APB_PROT_PRIVILEGED_CHECK_test extends apb_test;
  `uvm_component_utils(TC_APB_PROT_PRIVILEGED_CHECK_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_PROT_PRIVILEGED_CHECK_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_PROT_PRIVILEGED_CHECK seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_PROT_PRIVILEGED_CHECK::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_PRIVILEGED_CHECK: FAIL - unexpected scoreboard failure")
      
    else if (env.sb.skip_count > 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_PRIVILEGED_CHECK: FAIL - unexpected PSLVERR (slave not configured for priv check)")
      
    else if (env.sb.pass_count < 1)
      `uvm_error("TC_CHECK","TC_APB_PROT_PRIVILEGED_CHECK: FAIL - write did not pass")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_PROT_PRIVILEGED_CHECK: PASS - prot captured, no violation | txn=%0d",env.sb.txn_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_PROT_PRIVILEGED_CHECK_test

//---------------------------Testcase 15--------------------------------//

class TC_APB_PROT_SECURE_CHECK_test extends apb_test;
  `uvm_component_utils(TC_APB_PROT_SECURE_CHECK_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_PROT_SECURE_CHECK_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_PROT_SECURE_CHECK seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_PROT_SECURE_CHECK::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_SECURE_CHECK: FAIL - unexpected scoreboard failure")
      
    else if (env.sb.skip_count > 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_SECURE_CHECK: FAIL - unexpected PSLVERR")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_PROT_SECURE_CHECK: PASS - txn=%0d pass=%0d",env.sb.txn_count, env.sb.pass_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_PROT_SECURE_CHECK_test

//---------------------------Testcase 16--------------------------------//

class TC_APB_PROT_INSTR_CHECK_test extends apb_test;
  `uvm_component_utils(TC_APB_PROT_INSTR_CHECK_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_PROT_INSTR_CHECK_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_PROT_INSTR_CHECK seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_PROT_INSTR_CHECK::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_INSTR_CHECK: FAIL - unexpected scoreboard failure")
      
    else if (env.sb.skip_count > 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_INSTR_CHECK: FAIL - unexpected PSLVERR (ALLOW_INSTR=1)")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_PROT_INSTR_CHECK: PASS - txn=%0d pass=%0d",env.sb.txn_count, env.sb.pass_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_PROT_INSTR_CHECK_test

//---------------------------Testcase 17--------------------------------//

class TC_APB_PROT_COMBINATION_test extends apb_test;
  `uvm_component_utils(TC_APB_PROT_COMBINATION_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_PROT_COMBINATION_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_PROT_COMBINATION seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_PROT_COMBINATION::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_PROT_COMBINATION: FAIL - unexpected scoreboard failure")
      
    else if (env.sb.txn_count < 1)
      `uvm_error("TC_CHECK","TC_APB_PROT_COMBINATION: FAIL - no transaction recorded")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_PROT_COMBINATION: PASS - txn=%0d pass=%0d skip=%0d",env.sb.txn_count, env.sb.pass_count, env.sb.skip_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_PROT_COMBINATION_test

//---------------------------Testcase 18--------------------------------//

class TC_APB_RESET_DURING_ACCESS_test extends apb_test;
  `uvm_component_utils(TC_APB_RESET_DURING_ACCESS_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_RESET_DURING_ACCESS_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_RESET_DURING_ACCESS seq;

    phase.raise_objection(this);
    
    apply_reset();

    seq = TC_APB_RESET_DURING_ACCESS::type_id::create("seq");
    
    fork
      
      begin : DRIVE_TXN
        `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] Thread A: starting sequence", UVM_LOW)
        
        seq.start(env.m_agent.seqr);
        
        `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] Thread A: sequence completed (or aborted by reset)", UVM_LOW)
      end
      
      begin : INJECT_RESET
        `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] Thread B: waiting for SETUP phase (PSEL=1,PENABLE=0)", UVM_LOW)
        
        fork : SETUP_TIMEOUT
          
          begin
            @(posedge env_cfg.master_cfg.vif.PCLK);
            while (!(env_cfg.master_cfg.vif.PSEL   === 1'b1 && env_cfg.master_cfg.vif.PENABLE === 1'b0)) begin
              @(posedge env_cfg.master_cfg.vif.PCLK);
            end
          end
          
          begin
            repeat(50) @(posedge env_cfg.master_cfg.vif.PCLK);
            `uvm_fatal("TC_CHECK", "[RESET_DURING_ACCESS] TIMEOUT waiting for SETUP phase")
          end
          
        join_any
        disable SETUP_TIMEOUT;
        
        `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] Thread B: SETUP detected — waiting for ACCESS phase", UVM_LOW)
        
        fork : ACCESS_TIMEOUT
          
          begin
            @(posedge env_cfg.master_cfg.vif.PCLK);
            while (!(env_cfg.master_cfg.vif.PSEL   === 1'b1 && env_cfg.master_cfg.vif.PENABLE === 1'b1)) begin
              @(posedge env_cfg.master_cfg.vif.PCLK);
            end
          end
          
          begin
            repeat(50) @(posedge env_cfg.master_cfg.vif.PCLK);
            `uvm_fatal("TC_CHECK", "[RESET_DURING_ACCESS] TIMEOUT waiting for ACCESS phase")
          end
          
        join_any
        disable ACCESS_TIMEOUT;
        
        `uvm_info("TC_CHECK", $sformatf("[RESET_DURING_ACCESS] Thread B: ACCESS phase detected | PSEL=%0b PENABLE=%0b PREADY=%0b", env_cfg.master_cfg.vif.PSEL, env_cfg.master_cfg.vif.PENABLE, env_cfg.master_cfg.vif.PREADY), UVM_LOW)
        
        @(posedge env_cfg.master_cfg.vif.PCLK);
        
        `uvm_info("TC_CHECK", $sformatf("[RESET_DURING_ACCESS] Thread B: asserting PRESETn=0 NOW | PSEL=%0b PENABLE=%0b PREADY=%0b", env_cfg.master_cfg.vif.PSEL, env_cfg.master_cfg.vif.PENABLE, env_cfg.master_cfg.vif.PREADY), UVM_LOW)
        
        env_cfg.master_cfg.vif.PRESETn = 1'b0;
        
        repeat(3) 
          @(posedge env_cfg.master_cfg.vif.PCLK);
        
        env_cfg.master_cfg.vif.PRESETn = 1'b1;
        
        `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] Thread B: PRESETn released", UVM_LOW)
        
        repeat(5) @(posedge env_cfg.master_cfg.vif.PCLK);

      end

    join
    
    #200;
    if (env_cfg.master_cfg.vif.PSEL !== 1'b0)
      `uvm_error("TC_CHECK", "[RESET_DURING_ACCESS] FAIL — PSEL still high after reset")
      
    else
      `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] PASS — PSEL deasserted after reset", UVM_LOW)

    if (env_cfg.master_cfg.vif.PENABLE !== 1'b0)
      `uvm_error("TC_CHECK", "[RESET_DURING_ACCESS] FAIL — PENABLE still high after reset")
      
    else
      `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] PASS — PENABLE deasserted after reset", UVM_LOW)
      
    if (env_cfg.master_cfg.vif.done !== 1'b0)
      `uvm_error("TC_CHECK", "[RESET_DURING_ACCESS] FAIL — done is high after reset, expected 0 (txn aborted)")
      
    else
      `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] PASS — done=0 confirming transaction was aborted", UVM_LOW)
    
    if (env_cfg.master_cfg.vif.error !== 1'b0)
      `uvm_error("TC_CHECK", "[RESET_DURING_ACCESS] FAIL — error still high after reset")
      
    else
      `uvm_info("TC_CHECK", "[RESET_DURING_ACCESS] PASS — error=0 after reset", UVM_LOW)
      
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", $sformatf("[RESET_DURING_ACCESS] FAIL — unexpected scoreboard failures: %0d", env.sb.fail_count))
      
    else
      `uvm_info("TC_CHECK", $sformatf("[RESET_DURING_ACCESS] PASS — scoreboard clean after reset-aborted txn | txn=%0d warn=%0d", env.sb.txn_count, env.sb.warn_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_RESET_DURING_ACCESS_test

//---------------------------Testcase 19--------------------------------//

class TC_APB_DATA_STABILITY_test extends apb_test;
  `uvm_component_utils(TC_APB_DATA_STABILITY_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_DATA_STABILITY_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_DATA_STABILITY seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_DATA_STABILITY::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK",$sformatf("TC_APB_DATA_STABILITY: FAIL — read-back mismatch | fail=%0d",env.sb.fail_count))
      
    else if (env.sb.txn_count < 2)
      `uvm_error("TC_CHECK",$sformatf("TC_APB_DATA_STABILITY: FAIL - expected 2 txns got %0d",env.sb.txn_count))
      
    else if (env.sb.pass_count < 2)
      `uvm_error("TC_CHECK",$sformatf("TC_APB_DATA_STABILITY: FAIL - expected 2 passes got %0d",env.sb.pass_count))
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_DATA_STABILITY: PASS - data stable after write | txn=%0d pass=%0d",env.sb.txn_count, env.sb.pass_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_DATA_STABILITY_test

//---------------------------Testcase 20--------------------------------//

class TC_RANDOM_READ_WRITE_test extends apb_test;
  `uvm_component_utils(TC_RANDOM_READ_WRITE_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_RANDOM_READ_WRITE_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_RANDOM_READ_WRITE seq;
    
    phase.raise_objection(this);
    apply_reset();
    
    seq = TC_RANDOM_READ_WRITE::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK",$sformatf("TC_RANDOM_READ_WRITE: FAIL - %0d failures in %0d txns",env.sb.fail_count, env.sb.txn_count))
      
    else if (env.sb.txn_count < 10)
      `uvm_error("TC_CHECK",$sformatf("TC_RANDOM_READ_WRITE: FAIL - expected 10 txns got %0d",env.sb.txn_count))
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_RANDOM_READ_WRITE: PASS - txn=%0d pass=%0d warn=%0d skip=%0d",env.sb.txn_count, env.sb.pass_count,env.sb.warn_count, env.sb.skip_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_RANDOM_READ_WRITE_test

//---------------------------Testcase 21--------------------------------//

class TC_RANDOM_PSTRB_test extends apb_test;
  `uvm_component_utils(TC_RANDOM_PSTRB_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_RANDOM_PSTRB_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_RANDOM_PSTRB seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_RANDOM_PSTRB::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK", $sformatf("TC_RANDOM_PSTRB: FAIL - %0d failures", env.sb.fail_count))
    
    else if (env.sb.txn_count < 10)
      `uvm_error("TC_CHECK", $sformatf("TC_RANDOM_PSTRB: FAIL - expected 10 txns got %0d", env.sb.txn_count))
      
    else if ((env.sb.pass_count + env.sb.skip_count + env.sb.warn_count) < 10)
      
      `uvm_error("TC_CHECK", $sformatf("TC_RANDOM_PSTRB: FAIL - unexpected outcome txn=%0d pass=%0d skip=%0d warn=%0d fail=%0d", env.sb.txn_count, env.sb.pass_count, env.sb.skip_count, env.sb.warn_count, env.sb.fail_count))
      
    else
      `uvm_info("TC_CHECK", $sformatf("TC_RANDOM_PSTRB: PASS - txn=%0d pass=%0d skip=%0d", env.sb.txn_count, env.sb.pass_count, env.sb.skip_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_RANDOM_PSTRB_test

//---------------------------Testcase 22--------------------------------//

class TC_RANDOM_STRESS_test extends apb_test;
  `uvm_component_utils(TC_RANDOM_STRESS_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_RANDOM_STRESS_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_RANDOM_STRESS seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_RANDOM_STRESS::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK",$sformatf("TC_RANDOM_STRESS: FAIL - %0d failures in %0d txns",env.sb.fail_count, env.sb.txn_count))
      
    else if (env.sb.txn_count < 50)
      `uvm_error("TC_CHECK",$sformatf("TC_RANDOM_STRESS: FAIL - expected 50 txns got %0d",env.sb.txn_count))
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_RANDOM_STRESS: PASS - txn=%0d pass=%0d warn=%0d skip=%0d fail=%0d", env.sb.txn_count, env.sb.pass_count, env.sb.warn_count, env.sb.skip_count, env.sb.fail_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_RANDOM_STRESS_test

//---------------------------Testcase 23--------------------------------//

class TC_CONSTR_ADDR_test extends apb_test;
  `uvm_component_utils(TC_CONSTR_ADDR_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_CONSTR_ADDR_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_CONSTR_ADDR seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_CONSTR_ADDR::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_CONSTR_ADDR: FAIL - unexpected scoreboard failure")
      
    else if (env.sb.warn_count > 0)
      `uvm_error("TC_CHECK","TC_CONSTR_ADDR: FAIL - no slave responded for constrained addr")
      
    else if (env.sb.pass_count < 1)
      `uvm_error("TC_CHECK","TC_CONSTR_ADDR: FAIL - write did not pass")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_CONSTR_ADDR: PASS - slave0 addr range verified | txn=%0d", env.sb.txn_count), UVM_NONE)

    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_CONSTR_ADDR_test

//---------------------------Testcase 24--------------------------------//

class TC_CONSTR_STRB_test extends apb_test;
  `uvm_component_utils(TC_CONSTR_STRB_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_CONSTR_STRB_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_CONSTR_STRB seq;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_CONSTR_STRB::type_id::create("seq");
    seq.start(env.m_agent.seqr);
    
    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_CONSTR_STRB: FAIL - unexpected scoreboard failure")
      
    else if (env.sb.skip_count > 0)
      `uvm_error("TC_CHECK","TC_CONSTR_STRB: FAIL - unexpected PSLVERR for valid partial strobe")
      
    else if (env.sb.pass_count < 1)
      `uvm_error("TC_CHECK","TC_CONSTR_STRB: FAIL - partial write did not pass")
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_CONSTR_STRB: PASS - partial strobe write OK | txn=%0d pass=%0d",env.sb.txn_count, env.sb.pass_count), UVM_NONE)
      
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_CONSTR_STRB_test

//---------------------------Testcase 25--------------------------------//

class TC_APB_DONE_PULSE_WIDTH_test extends apb_test;
  `uvm_component_utils(TC_APB_DONE_PULSE_WIDTH_test)
  
  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="TC_APB_DONE_PULSE_WIDTH_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //---------------------------------------Run Phase---------------------------------------//
  task run_phase(uvm_phase phase);
    TC_APB_DONE_PULSE_WIDTH seq;
    
    int done_high_count;
    
    phase.raise_objection(this);
    
    apply_reset();
    
    seq = TC_APB_DONE_PULSE_WIDTH::type_id::create("seq");

    // Monitor done pulse width in parallel with sequence
    fork
      seq.start(env.m_agent.seqr);
      
      begin : DONE_PULSE_CHECK
        done_high_count = 0;
        
        repeat(20) begin
          
          @(posedge env_cfg.master_cfg.vif.PCLK);
          
          if (env_cfg.master_cfg.vif.done === 1'b1)
            done_high_count++;
          
        end
      end
    join

    #200;
    
    if (env.sb.fail_count != 0)
      `uvm_error("TC_CHECK","TC_APB_DONE_PULSE_WIDTH: FAIL - scoreboard failure")
      
    else if (done_high_count == 0)
      `uvm_error("TC_CHECK","TC_APB_DONE_PULSE_WIDTH: FAIL - done never went high")
      
    else if (done_high_count > 1)
      `uvm_error("TC_CHECK",$sformatf("TC_APB_DONE_PULSE_WIDTH: FAIL - done high for %0d cycles, expected 1",done_high_count))
      
    else
      `uvm_info("TC_CHECK",$sformatf("TC_APB_DONE_PULSE_WIDTH: PASS - done pulsed for exactly %0d cycle | txn=%0d",done_high_count, env.sb.txn_count), UVM_NONE)
     
    phase.drop_objection(this);
  endtask : run_phase
  
endclass : TC_APB_DONE_PULSE_WIDTH_test




class TC_REGRESSION_test extends apb_test;
  `uvm_component_utils(TC_REGRESSION_test)

  function new(string name="TC_REGRESSION_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);

    TC_APB_WRITE_SINGLE seq1;
    TC_APB_READ_SINGLE seq2;
    TC_APB_WRITE_READ_DIFF_ADDR  seq3;
    TC_APB_SLAVE0_ACCESS seq4;
    TC_APB_SLAVE1_ACCESS seq5;
    TC_APB_MULTI_SLAVE_ACCESS seq6;
    TC_APB_INVALID_SLAVE_SELECT seq7;
    TC_APB_WRITE_WITH_STRB_ZERO seq8;
    TC_APB_WRITE_WITH_STRB_PARTIAL seq9;
    TC_APB_WRITE_WITH_STRB_ALL seq10;
    TC_APB_WRITE_AFTER_RESET seq11;
    TC_APB_READ_AFTER_RESET seq12;
    TC_APB_PROT_PRIVILEGED_CHECK seq13;
    TC_APB_PROT_SECURE_CHECK seq14;
    TC_APB_PROT_INSTR_CHECK seq15;
    TC_APB_PROT_COMBINATION seq16;
    TC_APB_RESET_DURING_ACCESS seq17;
    TC_APB_DATA_STABILITY seq18;
    TC_RANDOM_READ_WRITE seq19;
    TC_RANDOM_PSTRB seq20;
    TC_RANDOM_STRESS seq21;
    TC_CONSTR_ADDR seq22;
    TC_CONSTR_STRB seq23;
    TC_APB_DONE_PULSE_WIDTH seq24;

    phase.raise_objection(this);

    `uvm_info("REGR","================================================================",UVM_NONE)
    `uvm_info("REGR","--------------------REGRESSION TEST — START---------------------",UVM_NONE)
    `uvm_info("REGR","================================================================",UVM_NONE)

    //--- Create all sequences ---//
    seq1  = TC_APB_WRITE_SINGLE::type_id::create("seq1");
    seq2  = TC_APB_READ_SINGLE::type_id::create("seq2");
    seq3  = TC_APB_WRITE_READ_DIFF_ADDR::type_id::create("seq3");
    seq4  = TC_APB_SLAVE0_ACCESS::type_id::create("seq4");
    seq5  = TC_APB_SLAVE1_ACCESS::type_id::create("seq5");
    seq6  = TC_APB_MULTI_SLAVE_ACCESS::type_id::create("seq6");
    seq7  = TC_APB_INVALID_SLAVE_SELECT::type_id::create("seq7");
    seq8  = TC_APB_WRITE_WITH_STRB_ZERO::type_id::create("seq8");
    seq9  = TC_APB_WRITE_WITH_STRB_PARTIAL::type_id::create("seq9");
    seq10 = TC_APB_WRITE_WITH_STRB_ALL::type_id::create("seq10");
    seq11 = TC_APB_WRITE_AFTER_RESET::type_id::create("seq11");
    seq12 = TC_APB_READ_AFTER_RESET::type_id::create("seq12");
    seq13 = TC_APB_PROT_PRIVILEGED_CHECK::type_id::create("seq13");
    seq14 = TC_APB_PROT_SECURE_CHECK::type_id::create("seq14");
    seq15 = TC_APB_PROT_INSTR_CHECK::type_id::create("seq15");
    seq16 = TC_APB_PROT_COMBINATION::type_id::create("seq16");
    seq17 = TC_APB_RESET_DURING_ACCESS::type_id::create("seq17");
    seq18 = TC_APB_DATA_STABILITY::type_id::create("seq18");
    seq19 = TC_RANDOM_READ_WRITE::type_id::create("seq19");
    seq20 = TC_RANDOM_PSTRB::type_id::create("seq20");
    seq21 = TC_RANDOM_STRESS::type_id::create("seq21");
    seq22 = TC_CONSTR_ADDR::type_id::create("seq22");
    seq23 = TC_CONSTR_STRB::type_id::create("seq23");
    seq24 = TC_APB_DONE_PULSE_WIDTH::type_id::create("seq24");

    //--- Run each sequence with its own reset ---//
    
    apply_reset();
    seq1.start(env.m_agent.seqr);
    `uvm_info("REGR","[01/24] TC_APB_WRITE_SINGLE - DONE",UVM_NONE)

//     apply_reset();
    seq2.start(env.m_agent.seqr);
    `uvm_info("REGR","[02/24] TC_APB_READ_SINGLE - DONE",UVM_NONE)

//     apply_reset();
    seq3.start(env.m_agent.seqr);
    `uvm_info("REGR","[03/24] TC_APB_WRITE_READ_DIFF_ADDR - DONE",UVM_NONE)

//     apply_reset();
    seq4.start(env.m_agent.seqr);
    `uvm_info("REGR","[04/24] TC_APB_SLAVE0_ACCESS - DONE",UVM_NONE)

//     apply_reset();
    seq5.start(env.m_agent.seqr);
    `uvm_info("REGR","[05/24] TC_APB_SLAVE1_ACCESS - DONE",UVM_NONE)

//     apply_reset();
    seq6.start(env.m_agent.seqr);
    `uvm_info("REGR","[06/24] TC_APB_MULTI_SLAVE_ACCESS - DONE",UVM_NONE)

//     apply_reset();
    seq7.start(env.m_agent.seqr);
    `uvm_info("REGR","[07/24] TC_APB_INVALID_SLAVE_SELECT - DONE",UVM_NONE)

//     apply_reset();
    seq8.start(env.m_agent.seqr);
    `uvm_info("REGR","[08/24] TC_APB_WRITE_WITH_STRB_ZERO - DONE",UVM_NONE)

//     apply_reset();
    seq9.start(env.m_agent.seqr);
    `uvm_info("REGR","[09/24] TC_APB_WRITE_WITH_STRB_PARTIAL - DONE",UVM_NONE)

//     apply_reset();
    seq10.start(env.m_agent.seqr);
    `uvm_info("REGR","[10/24] TC_APB_WRITE_WITH_STRB_ALL - DONE",UVM_NONE)

//     apply_reset();
    seq11.start(env.m_agent.seqr);
    `uvm_info("REGR","[11/24] TC_APB_WRITE_AFTER_RESET - DONE",UVM_NONE)

//     apply_reset();
    seq12.start(env.m_agent.seqr);
    `uvm_info("REGR","[12/24] TC_APB_READ_AFTER_RESET - DONE",UVM_NONE)

//     apply_reset();
    seq13.start(env.m_agent.seqr);
    `uvm_info("REGR","[13/24] TC_APB_PROT_PRIVILEGED_CHECK - DONE",UVM_NONE)

//     apply_reset();
    seq14.start(env.m_agent.seqr);
    `uvm_info("REGR","[14/24] TC_APB_PROT_SECURE_CHECK - DONE",UVM_NONE)

//     apply_reset();
    seq15.start(env.m_agent.seqr);
    `uvm_info("REGR","[15/24] TC_APB_PROT_INSTR_CHECK - DONE",UVM_NONE)

//     apply_reset();
    seq16.start(env.m_agent.seqr);
    `uvm_info("REGR","[16/24] TC_APB_PROT_COMBINATION - DONE",UVM_NONE)

    //------TC17 Reset During Access needs parallel reset injection----//
    apply_reset();
    `uvm_info("REGR","[17/24] TC_APB_RESET_DURING_ACCESS - STARTING",UVM_NONE)
    fork
      seq17.start(env.m_agent.seqr);
      begin : INJECT_RST
        // Wait for SETUP phase
        @(posedge env_cfg.master_cfg.vif.PCLK);
        while (!(env_cfg.master_cfg.vif.PSEL   === 1'b1 && env_cfg.master_cfg.vif.PENABLE === 1'b0))
          @(posedge env_cfg.master_cfg.vif.PCLK);
        // Wait for ACCESS phase
        @(posedge env_cfg.master_cfg.vif.PCLK);
        while (!(env_cfg.master_cfg.vif.PSEL   === 1'b1 && env_cfg.master_cfg.vif.PENABLE === 1'b1))
          @(posedge env_cfg.master_cfg.vif.PCLK);
        // One extra clock inside ACCESS then assert reset
        @(posedge env_cfg.master_cfg.vif.PCLK);
        env_cfg.master_cfg.vif.PRESETn = 1'b0;
        repeat(3) @(posedge env_cfg.master_cfg.vif.PCLK);
        env_cfg.master_cfg.vif.PRESETn = 1'b1;
        repeat(5) @(posedge env_cfg.master_cfg.vif.PCLK);
      end
    join
    `uvm_info("REGR","[17/24] TC_APB_RESET_DURING_ACCESS - DONE",UVM_NONE)

//     apply_reset();
    seq18.start(env.m_agent.seqr);
    `uvm_info("REGR","[18/24] TC_APB_DATA_STABILITY - DONE",UVM_NONE)

//     apply_reset();
    seq19.start(env.m_agent.seqr);
    `uvm_info("REGR","[19/24] TC_RANDOM_READ_WRITE - DONE",UVM_NONE)

//     apply_reset();
    seq20.start(env.m_agent.seqr);
    `uvm_info("REGR","[20/24] TC_RANDOM_PSTRB - DONE",UVM_NONE)

//     apply_reset();
    seq21.start(env.m_agent.seqr);
    `uvm_info("REGR","[21/24] TC_RANDOM_STRESS - DONE",UVM_NONE)

//     apply_reset();
    seq22.start(env.m_agent.seqr);
    `uvm_info("REGR","[22/24] TC_CONSTR_ADDR - DONE",UVM_NONE)

//     apply_reset();
    seq23.start(env.m_agent.seqr);
    `uvm_info("REGR","[23/24] TC_CONSTR_STRB - DONE",UVM_NONE)

//     apply_reset();
    seq24.start(env.m_agent.seqr);
    `uvm_info("REGR","[24/24] TC_APB_DONE_PULSE_WIDTH - DONE",UVM_NONE)

    #200;

    `uvm_info("REGR","================================================================",UVM_NONE)
    `uvm_info("REGR","===================REGRESSION TEST - COMPLETE===================",UVM_NONE)
    `uvm_info("REGR",$sformatf("SCOREBOARD: txn=%0d pass=%0d fail=%0d warn=%0d skip=%0d", env.sb.txn_count, env.sb.pass_count, env.sb.fail_count, env.sb.warn_count, env.sb.skip_count), UVM_NONE)
    `uvm_info("REGR", (env.sb.fail_count == 0) ? "  RESULT: ALL SEQUENCES PASSED " : $sformatf("  RESULT: SCOREBOARD FAILED (%0d)", env.sb.fail_count), UVM_NONE)
    `uvm_info("REGR","================================================================",UVM_NONE)

    if (env.sb.fail_count != 0)
      `uvm_error("REGR", $sformatf("REGRESSION FAILED — %0d scoreboard failures", env.sb.fail_count))

    phase.drop_objection(this);

  endtask : run_phase

endclass : TC_REGRESSION_test
