// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
`include "uvm_macros.svh"
`include "apb_package.sv"
`include "interface.sv"
import uvm_pkg::*;
import apb_package::*;
module apb_tb_tb;

  logic PCLK = 0;

  // ---------------- CLOCK ---------------- //
  always #5 PCLK = ~PCLK;

  // ---------------- INTERFACE ---------------- //
  apb_if vif(PCLK);

  // ---------------- DUT ---------------- //
  apb_top dut (
    .PCLK(PCLK),
    .PRESETn(vif.PRESETn),

    // USER SIDE
    .start(vif.start),
    .write(vif.write),
    .addr(vif.addr),
    .wdata(vif.wdata),
    .strb(vif.strb),
    .prot(vif.prot),

    .rdata(vif.rdata),
    .done(vif.done),
    .error(vif.error),

    // APB BUS SIGNALS
    .PSEL(vif.PSEL),
    .PENABLE(vif.PENABLE),
    .PWRITE(vif.PWRITE),

    .PADDR(vif.PADDR),
    .PWDATA(vif.PWDATA),
    .PSTRB(vif.PSTRB),
    .PPROT(vif.PPROT),

    .PRDATA(vif.PRDATA),
    .PREADY(vif.PREADY),
    .PSLVERR(vif.PSLVERR),

    .valid_slave(vif.valid_slave));

  // ---------------- RESET ---------------- //
  initial begin
    vif.PRESETn = 0;
    #20;
    vif.PRESETn = 1;
  end

  // ---------------- UVM ---------------- //
  initial begin
    $dumpfile("apb_top.vcd");
    $dumpvars(0, apb_tb_tb);

    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", vif);

    run_test("TC_REGRESSION_test");
  end

endmodule
