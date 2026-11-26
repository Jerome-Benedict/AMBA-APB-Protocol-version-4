class apb_master_monitor extends uvm_monitor;
  `uvm_component_utils(apb_master_monitor)

  virtual apb_if       vif;
  uvm_analysis_port #(apb_sequence_item) ap;
  apb_agent_config     cfg;

  function new(string name="apb_master_monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(apb_agent_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("MON", "cfg not found")
    vif = cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.PRESETn);
    @(posedge vif.PCLK);
    forever collect_transaction();
  endtask

  task collect_transaction();
    apb_sequence_item tr;

    //-------- WAIT FOR SETUP PHASE --------//
    forever begin
      @(posedge vif.PCLK);
      if (!vif.PRESETn) return;
      if (vif.PSEL && !vif.PENABLE) break;
    end

    tr = apb_sequence_item::type_id::create("tr", this);
    tr.write = vif.PWRITE;
    tr.addr = vif.PADDR;
    tr.wdata = vif.PWDATA;
    tr.strb = vif.PSTRB;
    tr.prot = vif.PPROT;

    //-------- WAIT FOR ACCESS PHASE COMPLETION --------//
    forever begin
      @(posedge vif.PCLK);
      if (!vif.PRESETn) begin
        `uvm_warning("MON", "Reset during txn - dropping")
        return;
      end

      if (vif.PSEL && vif.PENABLE) begin
        
        if (!vif.valid_slave) begin
          tr.error = 1;
          tr.rdata = 0;
          ap.write(tr);
          `uvm_info("MON",$sformatf("[MON] Invalid slave ADDR=0x%08h ERR=1", tr.addr),
            UVM_LOW)
          return;
        end
        
        if (vif.PREADY) begin
          if (!tr.write) tr.rdata = vif.PRDATA;
          tr.error = vif.PSLVERR;
          ap.write(tr);
          `uvm_info("Master_MON",$sformatf("[MON] ADDR=0x%08h WRITE=%0b RDATA=0x%08h ERR=%0b",tr.addr, tr.write, tr.rdata, tr.error), UVM_LOW)
//           `uvm_info("Master_MON", $sformatf("Captured Transaction from Master Monitor:\n%s", tr.sprint()), UVM_LOW)
          return;
        end
      end
    end
  endtask

endclass
