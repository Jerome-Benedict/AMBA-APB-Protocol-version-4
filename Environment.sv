class apb_env extends uvm_env;
  `uvm_component_utils(apb_env)

  apb_env_config   env_cfg;
  apb_master_agent m_agent;
  apb_slave_agent  s_agent[];
  apb_sb sb;
  apb_coverage cov;

  function new(string name="apb_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(apb_env_config)::get(this, "", "env_cfg", env_cfg))
      `uvm_fatal("ENV", "env_cfg not found")

    //-------- MASTER --------//
      
     uvm_config_db#(apb_agent_config)::set(this, "m_agent", "m_cfg", env_cfg.master_cfg);
    m_agent = apb_master_agent::type_id::create("m_agent", this);

    //-------- SLAVES --------//
    s_agent = new[env_cfg.num_slaves];
    foreach (s_agent[i]) begin
      
      uvm_config_db#(apb_slave_config)::set(this, $sformatf("s_agent[%0d]", i), "s_cfg", env_cfg.slave_cfg[i]);
      
      uvm_config_db#(int)::set(this, $sformatf("s_agent[%0d]", i), "slave_id", i);
      s_agent[i] = apb_slave_agent::type_id::create($sformatf("s_agent[%0d]", i), this);
    end

    //-------- SCOREBOARD --------//
    if (env_cfg.enable_scoreboard)
      sb = apb_sb::type_id::create("sb", this);

    //-------- COVERAGE --------//
    if (env_cfg.enable_coverage)
      cov = apb_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (env_cfg.enable_scoreboard) begin
      m_agent.mon.ap.connect(sb.master_fifo.analysis_export);
      foreach (s_agent[i])
        s_agent[i].mon.ap.connect(sb.slave_fifo[i].analysis_export);
    end

    if (env_cfg.enable_coverage)
      m_agent.mon.ap.connect(cov.analysis_imp);
  endfunction

endclass
