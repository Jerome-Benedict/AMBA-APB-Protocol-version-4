class apb_coverage extends uvm_component;
  `uvm_component_utils(apb_coverage)
  
  uvm_analysis_imp #(apb_sequence_item, apb_coverage) analysis_imp;
  apb_sequence_item tr;
  
  covergroup apb_cg;

  cp_write : coverpoint tr.write {bins READ  = {0};
                                  bins WRITE = {1};}
    
  cp_addr : coverpoint tr.addr[15:12] {bins slave0 = {4'h0};
                                       bins slave1 = {4'h1};
                                       bins invalid = {[4'h2:4'hF]};}
    
  cp_strb : coverpoint tr.strb {bins full = {4'b1111};
                                bins zero = {4'b0000};
                                bins single = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
                                bins partial[] = {[4'b0001:4'b1110]};}

  cp_prot : coverpoint tr.prot {bins all[] = {[3'b000:3'b111]};}

  cp_error : coverpoint tr.error {bins no_error = {0};
                                  bins error = {1};}

  cross_rw_addr  : cross cp_write, cp_addr;

    cross_addr_strb : cross cp_addr, cp_strb {ignore_bins invalid_addr = binsof(cp_addr.invalid);}

  cross_prot_rw  : cross cp_prot, cp_write;

    cross_err_addr : cross cp_error, cp_addr {ignore_bins no_error_invalid = binsof(cp_error.no_error) && binsof(cp_addr.invalid);}

endgroup : apb_cg

  //--------------------------------------- Constructor---------------------------------------//
  function new(string name="apb_coverage", uvm_component parent);
    super.new(name, parent);
    apb_cg = new();
    analysis_imp = new("analysis_imp", this);
  endfunction : new
  
  function void write(apb_sequence_item t);
    
    if (t == null)
      return;

    tr = t;
    
    if (tr.addr === 'x)
      return;

    apb_cg.sample();

  endfunction : write
  
  // ------------------------------------- Report Phase -------------------------------------- //
  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Coverage = %0.2f%%", apb_cg.get_coverage()),
      UVM_LOW)
  endfunction

endclass : apb_coverage
