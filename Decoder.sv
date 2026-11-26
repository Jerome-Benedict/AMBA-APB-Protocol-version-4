module apb_decoder(PADDR, PSEL, PSEL0, PSEL1, valid_slave);
  input [31:0] PADDR;
  input PSEL;
  output reg PSEL0, PSEL1, valid_slave;
  
  always @(*) begin
    PSEL0 = 0;
    PSEL1 = 0;
    valid_slave = 0;
    if(PSEL) begin
      case(PADDR[15:12])
        4'b0000: begin PSEL0 = 1; 
          			   valid_slave = 1; 
        		 end
        4'b0001: begin PSEL1 = 1; 
          		       valid_slave = 1; 
        		 end
        default: ;
      endcase
    end
  end

endmodule
