`include "uvm_macros.svh"
import uvm_pkg::*;

interface apb_if #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, NUM_SLAVES=2)(input logic PCLK);
  logic PRESETn;
  logic start, write;
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH/8-1:0] strb;
  logic [2:0] prot;

  logic [DATA_WIDTH-1:0] rdata;
  logic done, error, valid_slave;
  
  logic PSEL;
  logic PENABLE, PWRITE, PREADY, PSLVERR;
  logic [ADDR_WIDTH-1:0] PADDR;
  logic [DATA_WIDTH-1:0] PWDATA, PRDATA;
  logic [DATA_WIDTH/8-1:0] PSTRB;
  logic [2:0] PPROT;
  
  clocking cb_master_drv @(posedge PCLK);
    default input #1step output #1step;

    output start, write;
    output addr, wdata, strb, prot;
    input rdata, done, error;
    input valid_slave; 

  endclocking : cb_master_drv
  
  clocking cb_master_mon @(posedge PCLK);
    default input #1step;

    input PSEL, PENABLE, PWRITE;
    input PADDR, PWDATA, PRDATA;
    input PSTRB, PPROT;
    input PREADY, PSLVERR;
    input PRESETn;

  endclocking : cb_master_mon
  
  clocking cb_slave_mon @(posedge PCLK);
    default input #1step;

    input PSEL, PENABLE, PWRITE;
    input PADDR, PWDATA, PRDATA;
    input PSTRB, PPROT;
    input PREADY, PSLVERR;
    input PRESETn;

  endclocking : cb_slave_mon
  
  modport MASTER_DRV (clocking cb_master_drv, input PCLK, PRESETn);
  modport MASTER_MON (clocking cb_master_mon, input PCLK, PRESETn);
  modport SLAVE_MON (clocking cb_slave_mon, input PCLK, PRESETn);
    
  //------------------------------Assertions----------------------------//
    
  logic prev_done;
  logic [DATA_WIDTH-1:0] captured_prdata;
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) prev_done <= 0;
    else prev_done <= done;
  end
    
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      captured_prdata <= '0;
    else if (PSEL && PENABLE && PREADY && !PWRITE && valid_slave && !PSLVERR)
      captured_prdata <= PRDATA; 
  end
  
  //--------------------ASSERTION 1 - Reset Behavior----------------------//
   
  property p_reset_psel;
    @(posedge PCLK)
    !PRESETn |-> !PSEL;
  endproperty : p_reset_psel

  property p_reset_penable;
    @(posedge PCLK)
    !PRESETn |-> !PENABLE;
  endproperty : p_reset_penable

  property p_reset_done;
    @(posedge PCLK)
    !PRESETn |-> !done;
  endproperty : p_reset_done

  property p_reset_error;
    @(posedge PCLK)
    !PRESETn |-> !error;
  endproperty : p_reset_error

  A1_RESET_PSEL : assert property (p_reset_psel)
//     `uvm_info("A1-RESET", "PSEL de-asserted during reset", UVM_LOW)
    else 
      `uvm_error("A1-RESET", "PSEL not de-asserted during reset")

  A1_RESET_PENABLE : assert property (p_reset_penable)
//     `uvm_info("A1-RESET", "PENABLE de-asserted during reset", UVM_LOW)
    else 
      `uvm_error("A1-RESET", "PENABLE not de-asserted during reset")

  A1_RESET_DONE : assert property (p_reset_done)
//     `uvm_info("A1-RESET", "done de-asserted during reset", UVM_LOW)
    
    else 
      `uvm_error("A1-RESET", "done not de-asserted during reset")

  A1_RESET_ERROR : assert property (p_reset_error)
//     `uvm_info("A1-RESET", "error de-asserted during reset", UVM_LOW)
    
    else 
      `uvm_error("A1-RESET", "error not de-asserted during reset")
    
  //--------------------ASSERTION 2 - Setup Phase Validation--------------//
    
  property p_setup_penable_low;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && !PENABLE) |=> (PSEL && PENABLE);
  endproperty : p_setup_penable_low

  property p_setup_psel_stable;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && !PENABLE) |-> PSEL;
  endproperty : p_setup_psel_stable

  A2_SETUP_PENABLE_FOLLOWS : assert property (p_setup_penable_low)
//     `uvm_info("A2-SETUP", "PENABLE assert one cycle after SETUP (PSEL=1,PENABLE=0)", UVM_LOW)
    
    else 
      `uvm_error("A2-SETUP", "PENABLE did not assert one cycle after SETUP (PSEL=1,PENABLE=0)")

  A2_SETUP_PSEL_HIGH : assert property (p_setup_psel_stable)
//     `uvm_info("A2-SETUP", "PSEL deasserted expectedly in SETUP phase", UVM_LOW)
    
    else 
      `uvm_error("A2-SETUP", "PSEL deasserted unexpectedly in SETUP phase")
    
  //--------------------ASSERTION 3 - Access Phase Validation--------------//
    
  property p_access_psel_stable;
  	@(posedge PCLK) disable iff (!PRESETn)
  	(PSEL && PENABLE && !PREADY && !$past(PREADY)) |=> (PSEL && PENABLE);
  endproperty : p_access_psel_stable
    
  property p_access_paddr_stable;
  	@(posedge PCLK) disable iff (!PRESETn)
  	(PSEL && PENABLE && !PREADY && !$past(PREADY)) |=> $stable(PADDR);
  endproperty : p_access_paddr_stable
    
  property p_access_pwrite_stable;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && !PREADY && !$past(PREADY)) |=> $stable(PWRITE);
  endproperty : p_access_pwrite_stable

  property p_access_pwdata_stable;
  	@(posedge PCLK) disable iff (!PRESETn)
  	(PSEL && PENABLE && !PREADY && PWRITE && !$past(PREADY)) |=> $stable(PWDATA);
  endproperty : p_access_pwdata_stable

  A3_ACCESS_PSEL_STABLE : assert property (p_access_psel_stable)
//     `uvm_info("A3-ACCESS", "PSEL/PENABLE didn't dropped during wait state", UVM_LOW)
    
    else 
      `uvm_error("A3-ACCESS", "PSEL/PENABLE dropped during wait state")

  A3_ACCESS_PADDR_STABLE : assert property (p_access_paddr_stable)
//     `uvm_info("A3-ACCESS", "PADDR didn't changed during wait state", UVM_LOW)
    
    else 
      `uvm_error("A3-ACCESS", "PADDR changed during wait state")

  A3_ACCESS_PWRITE_STABLE : assert property (p_access_pwrite_stable)
//     `uvm_info("A3-ACCESS", "PWRITE didn't changed during wait state", UVM_LOW)
    
    else 
      `uvm_error("A3-ACCESS", "PWRITE changed during wait state")

  A3_ACCESS_PWDATA_STABLE : assert property (p_access_pwdata_stable)
//     `uvm_info("A3-ACCESS", "PWDATA didn't changed during wait state", UVM_LOW)
    
    else 
      `uvm_error("A3-ACCESS", "PWDATA changed during wait state")
    
  //--------------------ASSERTION 4 - Transfer Completion--------------//
    
  property p_pready_implies_done;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && valid_slave) |=> done;
  endproperty : p_pready_implies_done

  property p_done_clears_after_one_cycle;
    @(posedge PCLK) disable iff (!PRESETn)
    done |=> !done;
  endproperty : p_done_clears_after_one_cycle

  A4_PREADY_DONE : assert property (p_pready_implies_done)
//     `uvm_info("A4-COMPLETION", "PREADY=1 and done asserted next cycle", UVM_LOW)
    
    else 
      `uvm_error("A4-COMPLETION", "PREADY=1 but done not asserted next cycle")

  A4_DONE_ONE_CYCLE  : assert property (p_done_clears_after_one_cycle)
//     `uvm_info("A4-COMPLETION", "done stayed high for one cycle", UVM_LOW)
    else 
      `uvm_error("A4-COMPLETION", "done stayed high for more than one cycle")
    
  //--------------------ASSERTION 5 - Wait State Handling--------------//
    
  property p_wait_bus_held;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && !PREADY && !$past(PREADY)) |=> (PSEL && PENABLE && $stable(PADDR) && $stable(PWRITE) && $stable(PSTRB));
  endproperty : p_wait_bus_held
    
  A5_WAIT_STATE_STABLE : assert property (p_wait_bus_held)
//     `uvm_info("A5-WAIT", "Bus signals doesn't changed during PREADY=0 wait state", UVM_LOW)

    else 
      `uvm_error("A5-WAIT", "Bus signals changed during PREADY=0 wait state")
    
  //--------------------ASSERTION 6 - Read Operation Check--------------//
    
  property p_read_rdata_captured; 
    logic [DATA_WIDTH-1:0] prdata_snap;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && !PWRITE && valid_slave && !PSLVERR, prdata_snap = PRDATA) |=> (rdata == prdata_snap);
  endproperty : p_read_rdata_captured

  property p_read_no_write;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && !PWRITE) |-> !PWRITE;
  endproperty : p_read_no_write

  A6_READ_RDATA : assert property (p_read_rdata_captured)
//     `uvm_info("A6-READ", $sformatf("[PASS] READ rdata match | ADDR=0x%08h | expected=0x%08h | got=0x%08h", PADDR, captured_prdata, rdata), UVM_LOW)
  else
    `uvm_error("A6-READ", $sformatf("[FAIL] READ rdata mismatch | ADDR=0x%08h | expected=0x%08h | got=0x%08h",  PADDR, captured_prdata, rdata))

  A6_READ_NO_WRITE : assert property (p_read_no_write)
//     `uvm_info("A6-READ", "PWRITE is consistent during read", UVM_LOW)
  else
    `uvm_error("A6-READ", "PWRITE inconsistency during read")
    
  //--------------------ASSERTION 7 - Write Operation Check--------------//
    
  property p_write_pwdata_driven;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PWRITE) |-> (PWDATA !== 'x);
  endproperty : p_write_pwdata_driven

  property p_write_strb_nonzero_when_valid;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PWRITE && valid_slave && !PSLVERR) |-> (PSTRB !== 4'b0000);
  endproperty : p_write_strb_nonzero_when_valid

  A7_WRITE_PWDATA_VALID  : assert property (p_write_pwdata_driven)
//     `uvm_info("A7-WRITE", "PWDATA is data during write access", UVM_LOW)
    
    else 
      `uvm_error("A7-WRITE", "PWDATA is X during write access")

  A7_WRITE_STRB_NONZERO  : assert property (p_write_strb_nonzero_when_valid)
//     `uvm_info("A7-WRITE", "STRB != 0 on successful write", UVM_LOW)
    
    else 
      `uvm_error("A7-WRITE", "STRB=0 on successful write")
    
  //--------------------ASSERTION 8 - Byte Strobe Validation--------------//
    
  property p_strb_zero_gives_error;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && PWRITE && valid_slave && (PSTRB == 4'b0000)) |-> PSLVERR;
  endproperty : p_strb_zero_gives_error

  property p_strb_full_no_prot_error;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && PWRITE && valid_slave && (PSTRB == 4'b1111) && (PADDR < 256)) |-> !PSLVERR;
  endproperty : p_strb_full_no_prot_error

  A8_STRB_ZERO_ERROR : assert property (p_strb_zero_gives_error)
//     `uvm_info("A8-STRB", "PSTRB=0 write produce PSLVERR=1", UVM_LOW)
    
    else 
      `uvm_error("A8-STRB", "PSTRB=0 write did not produce PSLVERR=1")

  A8_STRB_FULL_OK    : assert property (p_strb_full_no_prot_error)
//     `uvm_info("A8-STRB", "PSTRB=1111 expectedly produced PSLVERR=0", UVM_LOW)
    
    else 
      `uvm_error("A8-STRB", "PSTRB=1111 unexpectedly produced PSLVERR")
    
  //--------------------ASSERTION 9 - Slave Selection (Decoder)--------------//
    
  property p_valid_slave_addr0;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && (PADDR[15:12] == 4'h0)) |-> valid_slave;
  endproperty : p_valid_slave_addr0

  property p_valid_slave_addr1;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && (PADDR[15:12] == 4'h1)) |-> valid_slave;
  endproperty : p_valid_slave_addr1

  property p_invalid_slave_no_valid;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && !(PADDR[15:12] inside {4'h0, 4'h1})) |-> !valid_slave;
  endproperty : p_invalid_slave_no_valid

  property p_invalid_slave_gives_error;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && !valid_slave) |=> error;
  endproperty : p_invalid_slave_gives_error

  A9_SLAVE0_DECODED : assert property (p_valid_slave_addr0)
//     `uvm_info("A9-DECODE", "addr[15:12]=0 and valid_slave=1", UVM_LOW)
    
    else 
      `uvm_error("A9-DECODE", "addr[15:12]=0 but valid_slave=0")

  A9_SLAVE1_DECODED : assert property (p_valid_slave_addr1)
//     `uvm_info("A9-DECODE", "addr[15:12]=1 and valid_slave=1", UVM_LOW)
    
    else 
      `uvm_error("A9-DECODE", "addr[15:12]=1 but valid_slave=0")

  A9_INVALID_NO_VALID : assert property (p_invalid_slave_no_valid)
//     `uvm_info("A9-DECODE", "invalid address and valid_slave=0", UVM_LOW)
    
    else 
      `uvm_error("A9-DECODE", "invalid address but valid_slave=1")

  A9_INVALID_GIVES_ERR : assert property (p_invalid_slave_gives_error)
//     `uvm_info("A9-DECODE", "invalid slave access produce error", UVM_LOW)
    
    else 
      `uvm_error("A9-DECODE", "invalid slave access did not produce error")
    
  //--------------------ASSERTION 10 - MUX Output Validation--------------//
    
  property p_mux_prdata_defined_on_valid_read;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && !PWRITE && valid_slave && !PSLVERR) |-> (PRDATA !== 'x);
  endproperty : p_mux_prdata_defined_on_valid_read

  property p_mux_prdata_zero_on_invalid;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && !valid_slave) |-> (PRDATA == '0);
  endproperty : p_mux_prdata_zero_on_invalid

  A10_MUX_PRDATA_VALID : assert property (p_mux_prdata_defined_on_valid_read)
//     `uvm_info("A10-MUX", "PRDATA have data on valid read", UVM_LOW)
    
    else 
      `uvm_error("A10-MUX", "PRDATA is X on valid read")

  A10_MUX_PRDATA_INVALID : assert property (p_mux_prdata_zero_on_invalid)
//     `uvm_info("A10-MUX", "PRDATA is zero on invalid slave access", UVM_LOW)
    
    else 
      `uvm_error("A10-MUX", "PRDATA non-zero on invalid slave access")

  //--------------------ASSERTION 11 - Error Handling--------------//
    
  property p_pslverr_only_in_access;
    @(posedge PCLK) disable iff (!PRESETn)
    PSLVERR |-> (PSEL && PENABLE && PREADY);
  endproperty : p_pslverr_only_in_access

  property p_error_tracks_pslverr;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && valid_slave) |=> (error == $past(PSLVERR));
  endproperty : p_error_tracks_pslverr

  A11_PSLVERR_ONLY_ACCESS : assert property (p_pslverr_only_in_access)
//     `uvm_error("A11-ERROR", "PSLVERR didn't asserted outside ACCESS phase")
    
    else 
      `uvm_info("A11-ERROR", "PSLVERR asserted outside ACCESS phase", UVM_LOW)

  A11_ERROR_TRACKS_PSLVERR : assert property (p_error_tracks_pslverr)
//     `uvm_info("A11-ERROR", "error track PSLVERR", UVM_LOW)
    
    else 
      `uvm_error("A11-ERROR", "error does not track PSLVERR")
    
  //--------------------ASSERTION 12 - Protection Signal Validation--------------//
  
  property p_pprot_not_x_in_access;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE) |-> (PPROT !== 'x);
  endproperty : p_pprot_not_x_in_access
    
  property p_pprot_stable_in_wait;
  	@(posedge PCLK) disable iff (!PRESETn)
  	(PSEL && PENABLE && !PREADY && !$past(PREADY)) |=> $stable(PPROT);
  endproperty : p_pprot_stable_in_wait
    
  property p_prot_default_no_violation;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PREADY && valid_slave && (PSTRB != 4'b0000) && (PADDR[7:0] < 256)) |-> !PSLVERR;
  endproperty : p_prot_default_no_violation

  A12_PPROT_NOT_X : assert property (p_pprot_not_x_in_access)
//     `uvm_info("A12-PROT", "PPROT is high during ACCESS", UVM_LOW)
    
    else 
      `uvm_error("A12-PROT", "PPROT is X during ACCESS")

  A12_PPROT_STABLE_WAIT : assert property (p_pprot_stable_in_wait)
//     `uvm_info("A12-PROT", "PPROT didn't changed during wait state", UVM_LOW)
    
    else 
      `uvm_error("A12-PROT", "PPROT changed during wait state")

  A12_PROT_DEFAULT_OK : assert property (p_prot_default_no_violation)
//     `uvm_info("A12-PROT", "Expected PSLVERR with default protection settings", UVM_LOW)
    
    else 
      `uvm_error("A12-PROT", "Unexpected PSLVERR with default protection settings")
    
  //--------------------ASSERTION 13 - Idle State Check--------------//
  
  property p_idle_psel_low;
    @(posedge PCLK) disable iff (!PRESETn)
    (!PSEL) |-> !PENABLE;
  endproperty : p_idle_psel_low

  property p_idle_done_low;
    @(posedge PCLK) disable iff (!PRESETn)
    (!PSEL && !PENABLE) |-> !done;
  endproperty : p_idle_done_low
    
  property p_returns_to_idle_after_done;
    @(posedge PCLK) disable iff (!PRESETn)
    done |=> !PSEL;
  endproperty : p_returns_to_idle_after_done

  A13_IDLE_PENABLE_LOW : assert property (p_idle_psel_low)
//     `uvm_info("A13-IDLE", "PENABLE=0 while PSEL=0", UVM_LOW)
    
    else 
      `uvm_error("A13-IDLE", "PENABLE=1 while PSEL=0")

  A13_IDLE_DONE_LOW : assert property (p_idle_done_low)
//     `uvm_info("A13-IDLE", "done=0 while bus idle", UVM_LOW)
    
    else 
      `uvm_error("A13-IDLE", "done=1 while bus idle")

  A13_RETURNS_TO_IDLE : assert property (p_returns_to_idle_after_done)
//     `uvm_info("A13-IDLE", "PSEL de-asserted after done", UVM_LOW)
    
    else 
      `uvm_error("A13-IDLE", "PSEL not de-asserted after done")
    
  //--------------------ASSERTION 14 - Back-to-Back Transfer Check--------------//
  
  property p_no_setup_during_access;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && !PREADY && !$past(PREADY)) |=> (PSEL && PENABLE);
  endproperty
    
  property p_gap_between_transfers;
    @(posedge PCLK) disable iff (!PRESETn)
    done |=> !PENABLE;
  endproperty
    
  property p_start_not_during_access;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE) |-> !start;
  endproperty

  A14_NO_SETUP_IN_ACCESS  : assert property (p_no_setup_during_access)
//     `uvm_info("A14-BTB", "ACCESS phase ended after PREADY", UVM_LOW)
    
    else 
      `uvm_error("A14-BTB", "ACCESS phase ended prematurely before PREADY")

  A14_GAP_AFTER_DONE      : assert property (p_gap_between_transfers)
//     `uvm_info("A14-BTB", "PENABLE becomes low immediately after done", UVM_LOW)
    
    else 
      `uvm_error("A14-BTB", "PENABLE still high immediately after done")

  A14_NO_START_IN_ACCESS  : assert property (p_start_not_during_access)
//     `uvm_info("A14-BTB", "start doesn't asserted while bus is in ACCESS", UVM_LOW)
   
    else 
      `uvm_error("A14-BTB", "start asserted while bus is in ACCESS")

endinterface : apb_if
