`include "master.sv"
`include "slave.sv"
`include "decoder.sv"
`include "mux.sv"
module apb_top #(parameter ADDR_WIDTH=32, DATA_WIDTH=32)(
  input PCLK,
  input PRESETn,

  // User side
  input start,
  input write,
  input [ADDR_WIDTH-1:0] addr,
  input [DATA_WIDTH-1:0] wdata,
  input [DATA_WIDTH/8-1:0] strb,
  input [2:0] prot,

  output [DATA_WIDTH-1:0] rdata,
  output done,
  output error,

  // APB protocol signals exported to interface
  output PSEL,
  output PENABLE,
  output PWRITE,
  output [ADDR_WIDTH-1:0] PADDR,
  output [DATA_WIDTH-1:0] PWDATA,
  output [DATA_WIDTH/8-1:0] PSTRB,
  output [2:0] PPROT,

  output [DATA_WIDTH-1:0] PRDATA,
  output PREADY,
  output PSLVERR,

  output valid_slave
);

  // ------------------------------------------------------------------
  // Internal wires
  // ------------------------------------------------------------------

  wire PSEL0;
  wire PSEL1;

  wire [DATA_WIDTH-1:0] PRDATA0;
  wire [DATA_WIDTH-1:0] PRDATA1;

  wire PREADY0;
  wire PREADY1;

  wire PSLVERR0;
  wire PSLVERR1;

  // ------------------------------------------------------------------
  // MASTER
  // ------------------------------------------------------------------

  apb4_master #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)) 
     master (
    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .start(start),
    .write(write),
    .addr(addr),
    .wdata(wdata),
    .strb(strb),
    .prot(prot),

    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .valid_slave(valid_slave),

    .rdata(rdata),
    .done(done),
    .error(error),

    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PPROT(PPROT));

  // ------------------------------------------------------------------
  // DECODER
  // ------------------------------------------------------------------

  apb_decoder decoder (
    .PADDR(PADDR),
    .PSEL(PSEL),

    .PSEL0(PSEL0),
    .PSEL1(PSEL1),

    .valid_slave(valid_slave));

  // ------------------------------------------------------------------
  // SLAVE 0
  // ------------------------------------------------------------------

  apb4_slave #(
    .ADDR_WIDTH(8),
    .DATA_WIDTH(DATA_WIDTH)) 
     slave0 (
    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .PSEL(PSEL0),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),

    .PADDR(PADDR[7:0]),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PPROT(PPROT),

    .PRDATA(PRDATA0),
    .PREADY(PREADY0),
    .PSLVERR(PSLVERR0)
  );

  // ------------------------------------------------------------------
  // SLAVE 1
  // ------------------------------------------------------------------

  apb4_slave #(
    .ADDR_WIDTH(8),
    .DATA_WIDTH(DATA_WIDTH)) 
     slave1 (
    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .PSEL(PSEL1),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),

    .PADDR(PADDR[7:0]),
    .PWDATA(PWDATA),
    .PSTRB(PSTRB),
    .PPROT(PPROT),

    .PRDATA(PRDATA1),
    .PREADY(PREADY1),
    .PSLVERR(PSLVERR1)
  );

  // ------------------------------------------------------------------
  // MUX
  // ------------------------------------------------------------------

  apb_slave_mux #(
    .DATA_WIDTH(DATA_WIDTH)) 
     mux (
    .PSEL0(PSEL0),
    .PSEL1(PSEL1),

    .PRDATA0(PRDATA0),
    .PRDATA1(PRDATA1),

    .PREADY0(PREADY0),
    .PREADY1(PREADY1),

    .PSLVERR0(PSLVERR0),
    .PSLVERR1(PSLVERR1),

    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
  );

endmodule
