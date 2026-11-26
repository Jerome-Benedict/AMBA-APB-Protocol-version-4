class apb_slave_monitor extends uvm_monitor;
  `uvm_component_utils(apb_slave_monitor)
  virtual apb_if vif;
  uvm_analysis_port #(apb_sequence_item) ap;
  apb_slave_config cfg;
  bit [31:0] start_addr;
  bit [31:0] end_addr;
  int slave_id;

  //-------------------------------- Constructor --------------------------------//
  function new(string name="apb_slave_monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  //-------------------------------- Build Phase --------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(apb_slave_config)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "Slave monitor config missing")
    if (!uvm_config_db#(int)::get(this, "", "slave_id", slave_id))
      `uvm_fatal("NOID", "slave_id missing")
    vif        = cfg.vif;
    start_addr = cfg.start_addr;
    end_addr   = cfg.end_addr;
  endfunction

  //-------------------------------- Run Phase --------------------------------//
  task run_phase(uvm_phase phase);
    @(posedge vif.PRESETn);
    forever begin
      collect_transfer();
    end
  endtask

  //-------------------------------- Collect Transfer --------------------------------//
  task collect_transfer();
    apb_sequence_item tr;

    //-------------------------------- WAIT SETUP --------------------------------//
    forever begin
      @(posedge vif.PCLK);
      if (!vif.PRESETn) continue;
      if (vif.PSEL &&
          vif.PADDR[15:12] == slave_id[3:0] && !vif.PENABLE)
        break;
    end

    //-------------------------------- CREATE TXN --------------------------------//
    tr        = apb_sequence_item::type_id::create("tr", this);
    tr.write  = vif.PWRITE;
    tr.addr   = vif.PADDR;
    tr.wdata  = vif.PWDATA;
    tr.strb   = vif.PSTRB;
    tr.prot   = vif.PPROT;

    //-------------------------------- WAIT ACCESS --------------------------------//
    forever begin
      @(posedge vif.PCLK);

      //---------------- RESET DURING TRANSFER ----------------//
      if (!vif.PRESETn) begin
        tr.error = 1;
        `uvm_warning("SLV_MON", "Reset detected during transfer")
        ap.write(tr);
        return;
      end

      //---------------- ACCESS COMPLETE ----------------//
      // FIX: Same change here — use addr[15:12] instead of range check
      if (vif.PSEL && vif.PADDR[15:12] == slave_id[3:0] && vif.PENABLE && vif.PREADY)
      begin
        if (!tr.write)
          tr.rdata = vif.PRDATA;
        tr.error = vif.PSLVERR;
        ap.write(tr);
        `uvm_info("SLV_MON", $sformatf("Slave%0d Txn ADDR=0x%08h WRITE=%0b DATA=0x%08h ERR=%0b", slave_id, tr.addr, tr.write, tr.write ? tr.wdata : tr.rdata, tr.error), UVM_MEDIUM)
//         `uvm_info("SLV_MON", $sformatf("Captured Transaction from Slave Monitor:\n%s", tr.sprint()), UVM_LOW)
        break;
      end
    end
  endtask

endclass : apb_slave_monitor
