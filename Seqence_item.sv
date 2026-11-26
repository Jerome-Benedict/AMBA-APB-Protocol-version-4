class apb_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(apb_sequence_item)
  
  rand bit write;
  rand bit [31:0] addr;
  rand bit [31:0] wdata;
  rand bit [3:0] strb;
  rand bit [2:0] prot;
  bit [31:0] rdata;
  bit error, inject_reset;
  bit allow_strb_zero = 0;
  
//--------------------------Constraints-------------------//
  constraint addr_c {soft addr[15:12] inside {4'h0, 4'h1};
                     addr[1:0] == 2'b00;}
  
  constraint strb_c {if (!allow_strb_zero) strb != 4'b0000;}
  
  constraint rw_c {if (!write) 
    				wdata == 32'h0;}
  
//   constraint align_c {addr[1:0] == 2'b00;}
  
  constraint write_dist_c {write dist {0 := 1, 1 := 1};}
  
  constraint prot_dist_c {prot dist {3'b000 := 3, 3'b001 := 1, 3'b010 := 1, 3'b100 := 1, [3'b011:3'b111] := 1};}
  
//-----------------------Constructor---------------------//
  function new(string name = "apb_sequence_item");
    super.new(name);
  endfunction : new
  
//----------------------Print-------------------//
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("write", write, 1);
    printer.print_field("addr", addr, 32);
    printer.print_field("wdata", wdata, 32);
    printer.print_field("rdata", rdata, 32);
    printer.print_field("strb", strb, 4);
    printer.print_field("prot", prot, 3);
    printer.print_field("error", error, 1);
    printer.print_field("allow_strb_zero", allow_strb_zero, 1);
  endfunction : do_print
  
endclass : apb_sequence_item
