 module apb_slave_mux #(parameter DATA_WIDTH=32)(
  input PSEL0, PSEL1,
  input [DATA_WIDTH-1:0] PRDATA0, PRDATA1,
  input PREADY0, PREADY1,
  input PSLVERR0, PSLVERR1,
  output reg [DATA_WIDTH-1:0] PRDATA,
  output reg PREADY, PSLVERR);
  
  always @(*) begin
    case ({PSEL1, PSEL0})
      2'b01: begin
        PRDATA = PRDATA0;
        PREADY = PREADY0;
        PSLVERR = PSLVERR0;
      end
      
      2'b10: begin
        PRDATA = PRDATA1;
        PREADY = PREADY1;
        PSLVERR = PSLVERR1;
      end
      
      2'b11: begin
        PRDATA = 0;
        PREADY = 1;
        PSLVERR = 1;
      end
      
      default: begin
        PRDATA = 0;
        PREADY = 0;
        PSLVERR = 1;
      end
    endcase
  end

endmodule
