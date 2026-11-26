module apb4_master #(parameter ADDR_WIDTH=32, DATA_WIDTH=32)(
  input PCLK, PRESETn, start, write,
  input [ADDR_WIDTH-1:0] addr,
  input [DATA_WIDTH-1:0] wdata,
  input [DATA_WIDTH/8-1:0] strb,
  input [2:0] prot,
  input [DATA_WIDTH-1:0] PRDATA,
  input PREADY, PSLVERR, valid_slave,
  output reg [DATA_WIDTH-1:0] rdata,
  output reg done, error,
  output reg PSEL, PENABLE, PWRITE,
  output reg [ADDR_WIDTH-1:0] PADDR,
  output reg [DATA_WIDTH-1:0] PWDATA,
  output reg [DATA_WIDTH/8-1:0] PSTRB,
  output reg [2:0] PPROT
);

  typedef enum logic [1:0] {IDLE=2'b00, SETUP=2'b01, ACCESS=2'b10} state_t;
  state_t state;

  //-------- STATE MACHINE --------//
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) 
      state <= IDLE;
    
    else case (state)
      IDLE  : if (start) 
        state <= SETUP;
      
      SETUP : state <= ACCESS;
      
      ACCESS: if (!valid_slave || PREADY)     
        state <= IDLE;
      default: state <= IDLE;
    endcase
  end

  //-------- OUTPUT REGISTERS --------//
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      PSEL <= 0; 
      PENABLE <= 0; 
      PWRITE <= 0;
      PADDR <= 0; 
      PWDATA <= 0; 
      PSTRB <= 0; 
      PPROT <= 0;
      error <= 0; 
      rdata <= 0; 
      done <= 0;
    end
    else case (state)
      IDLE: begin
        PSEL <= 0; 
        PENABLE <= 0;
        PWRITE <= 0; 
        error <= 0; 
        done <= 0;
      end
      SETUP: begin
        PSEL <= 1; 
        PENABLE <= 0;
        PADDR <= addr;  
        PWRITE <= write;
        PWDATA <= wdata; 
        PSTRB <= strb; 
        PPROT <= prot;
        done <= 0;
      end
      ACCESS: begin
        PSEL <= 1;
        PENABLE <= 1;
        if (!valid_slave) begin
          error <= 1;
          done <= 0;
        end
        else if (PREADY) begin
          error <= PSLVERR;
          done <= 1;
          if (!PWRITE) 
            rdata <= PRDATA;
        end
        else begin
          done <= 0;
        end
      end
    endcase
  end

endmodule
