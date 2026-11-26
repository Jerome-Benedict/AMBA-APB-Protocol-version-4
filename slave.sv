module apb4_slave #(parameter ADDR_WIDTH = 8, parameter DATA_WIDTH = 32, parameter DEPTH = 256, parameter REQUIRE_PRIVILEGED = 0, parameter REQUIRE_SECURE = 0, parameter ALLOW_INSTR = 1, parameter WAIT_STATES = 2)(
  input PCLK,
  input PRESETn,
  input PSEL,
  input PENABLE,
  input PWRITE,
  input [ADDR_WIDTH-1:0]PADDR,
  input [DATA_WIDTH-1:0]PWDATA,
  input [DATA_WIDTH/8-1:0]PSTRB,
  input [2:0]PPROT,
  output reg [DATA_WIDTH-1:0]PRDATA,
  output PREADY,
  output PSLVERR);

  initial begin
    if (WAIT_STATES > 2) begin
      $fatal(1, "apb4_slave: WAIT_STATES=%0d is invalid. Only 0, 1, or 2 are supported.", WAIT_STATES);
    end
  end
  
  //-------- Internal signals--------//
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  reg [1:0] wait_cnt;
  integer i, j;

  //-------- Protection checks --------//
  wire addr_valid = (PADDR < DEPTH);
  wire priv_violation = (REQUIRE_PRIVILEGED && (PPROT[0] == 1'b0));
  wire sec_violation = (REQUIRE_SECURE && (PPROT[1] == 1'b1));
  wire instr_violation = (!ALLOW_INSTR && (PPROT[2] == 1'b1));
  
  wire prot_error = priv_violation | sec_violation | instr_violation;
  
  wire strb_zero_write = PWRITE && (PSTRB == {(DATA_WIDTH/8){1'b0}});
  
  wire access_error = !addr_valid | prot_error | strb_zero_write;

  //-------- PREADY / PSLVERR --------//
  assign PREADY = (PSEL && PENABLE) && (wait_cnt == WAIT_STATES[1:0]);
  assign PSLVERR = (PSEL && PENABLE && PREADY && access_error);

  //-------- Wait counter --------//
  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      wait_cnt <= 2'd0;
    else if (PSEL && PENABLE && !PREADY)
      wait_cnt <= wait_cnt + 1;
    else
      wait_cnt <= 2'd0;
  end

  //-------- Memory reset --------//
  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      for (j = 0; j < DEPTH; j = j + 1)
        mem[j] <= {DATA_WIDTH{1'b0}};
    end
  end

  //-------- Write --------//
  always @(posedge PCLK) begin
    if (PSEL && PENABLE && PREADY && PWRITE && addr_valid && !prot_error && !strb_zero_write) begin
      for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
        if (PSTRB[i])
          mem[PADDR][8*i +: 8] <= PWDATA[8*i +: 8];
      end
    end
  end
  
  always @(*) begin
    if (PSEL && PENABLE && !PWRITE && addr_valid && !prot_error)
      PRDATA = mem[PADDR];
    else
      PRDATA = {DATA_WIDTH{1'b0}};
  end

endmodule
