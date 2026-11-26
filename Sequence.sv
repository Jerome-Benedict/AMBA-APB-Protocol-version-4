class apb_sequence extends uvm_sequence #(apb_sequence_item);
  `uvm_object_utils(apb_sequence)

//----------------------Constructor------------------//  
  function new(string name="apb_sequence");
      super.new(name);
  endfunction : new
  
endclass : apb_sequence

//---------------------------TC_APB_WRITE_READ_SAME_ADDR------------------//

//----------------------------TC_APB_WRITE_SINGLE---------------------//
class TC_APB_WRITE_SINGLE extends apb_sequence;
  `uvm_object_utils(TC_APB_WRITE_SINGLE)
  
  //----------------------Constructor------------------//  
  function new(string name="TC_APB_READ_SINGLE");
      super.new(name);
  endfunction : new
  
  virtual task body();
    apb_sequence_item req;
    req = apb_sequence_item::type_id::create("TC_APB_WRITE_SINGLE");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 addr  == 32'h0000_0010;
                                 strb  == 4'b1111;});
    finish_item(req);
  endtask : body
endclass : TC_APB_WRITE_SINGLE


//----------------------------TC_APB_READ_SINGLE----------------------//
class TC_APB_READ_SINGLE extends apb_sequence;
  `uvm_object_utils(TC_APB_READ_SINGLE)
  
  //----------------------Constructor------------------//  
  function new(string name="TC_APB_READ_SINGLE");
      super.new(name);
  endfunction : new
  
  virtual task body();
    apb_sequence_item req;
    req = apb_sequence_item::type_id::create("TC_APB_READ_SINGLE");
    start_item(req);
    assert(req.randomize() with {write == 0;
                                 addr == 32'h0000_0010;});
    finish_item(req);
  endtask : body
endclass : TC_APB_READ_SINGLE

//---------------------------TC_APB_WRITE_READ_DIFF_ADDR------------------//

class TC_APB_WRITE_READ_DIFF_ADDR extends apb_sequence;
  `uvm_object_utils(TC_APB_WRITE_READ_DIFF_ADDR)
  
  //----------------------Constructor------------------//  
  function new(string name="TC_APB_WRITE_READ_DIFF_ADDR");
      super.new(name);
  endfunction : new
  
  virtual task body();
    apb_sequence_item req;
    
    //---------------------Write--------------------//
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 addr == 32'h0000_0010;
                                 strb == 4'b1111;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 0;
                                 addr == 32'h0000_0010; });
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 0;
                                 addr == 32'h0000_0020; });
    finish_item(req);
  endtask : body
endclass : TC_APB_WRITE_READ_DIFF_ADDR

//------------------------------TC_APB_SLAVE0_ACCESS-----------------------//
class TC_APB_SLAVE0_ACCESS extends apb_sequence;
  `uvm_object_utils(TC_APB_SLAVE0_ACCESS)
  
  function new(string name="TC_APB_SLAVE0_ACCESS");
    super.new(name);
  endfunction
  
  virtual task body();
    apb_sequence_item req;
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1; 
                                 addr[15:12] == 4'h0;
                                 addr[1:0] == 2'b00;
                                 strb == 4'b1111; });
    finish_item(req);
  endtask
  
endclass

//------------------------------TC_APB_SLAVE1_ACCESS-----------------------//

class TC_APB_SLAVE1_ACCESS extends apb_sequence;
  `uvm_object_utils(TC_APB_SLAVE1_ACCESS)
  
  function new(string name="TC_APB_SLAVE1_ACCESS");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 addr[15:12] == 4'h1;
                                 addr[1:0] == 2'b00;
                                 strb == 4'b1111;});
    finish_item(req);
  endtask
  
endclass

//-----------------------------TC_APB_MULTI_SLAVE_ACCESS-----------------//

class TC_APB_MULTI_SLAVE_ACCESS extends apb_sequence;
  `uvm_object_utils(TC_APB_MULTI_SLAVE_ACCESS)
  
  function new(string name="TC_APB_MULTI_SLAVE_ACCESS");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    // Write slave0
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { write == 1; 
                                 addr[15:12] == 4'h0;
                                 addr[1:0] == 2'b00; 
                                 strb == 4'b1111;});
    finish_item(req);
    
    // Write slave1
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { write == 1; 
                                 addr[15:12] == 4'h1;
                                 addr[1:0] == 2'b00; 
                                 strb == 4'b1111;});
    finish_item(req);
  endtask
  
endclass

//-----------------------------TC_APB_INVALID_SLAVE_SELECT-----------------//

class TC_APB_INVALID_SLAVE_SELECT extends apb_sequence;
  `uvm_object_utils(TC_APB_INVALID_SLAVE_SELECT)
  
  function new(string name="TC_APB_INVALID_SLAVE_SELECT");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 addr[15:12] inside {[4'h2 : 4'hF]};
                                 addr[1:0] == 2'b00;});
    
    finish_item(req);
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    
    assert(req.randomize() with {write == 0;
                                 addr[15:12] inside {[4'h2 : 4'hF]};
                                 addr[1:0] == 2'b00;});
    
    finish_item(req);
    
  endtask
  
endclass

//-----------------------------TC_APB_WRITE_WITH_STRB_ZERO-------------------//

class TC_APB_WRITE_WITH_STRB_ZERO extends apb_sequence;
  `uvm_object_utils(TC_APB_WRITE_WITH_STRB_ZERO)

  function new(string name="TC_APB_WRITE_WITH_STRB_ZERO");
    super.new(name);
  endfunction

  virtual task body();
    apb_sequence_item req;
    bit [31:0] saved_addr;

    // The STRB=0 write — expect PSLVERR=1
    req = apb_sequence_item::type_id::create("req");
    req.allow_strb_zero = 1;
    start_item(req);
    assert(req.randomize() with { write == 1;
                                  strb  == 4'b0000;
                                  addr[1:0] == 2'b00; 
                                 addr[15:12] == 4'h0;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    req.allow_strb_zero = 1;
    start_item(req);
    assert(req.randomize() with { write == 1;
                                  strb  == 4'b0000;
                                  addr[1:0] == 2'b00;
                                addr[15:12] == 4'h1;});
    finish_item(req);
    
  endtask

endclass

//----------------------------TC_APB_WRITE_WITH_STRB_PARTIAL---------------//

class TC_APB_WRITE_WITH_STRB_PARTIAL extends apb_sequence;
  `uvm_object_utils(TC_APB_WRITE_WITH_STRB_PARTIAL)
  
  function new(string name="TC_APB_WRITE_WITH_STRB_PARTIAL");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    repeat(5) begin
      req = apb_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {write == 1;
                                   strb inside {4'b0001, 4'b0011, 4'b0111};});
      
      finish_item(req);
    end
    
  endtask
  
endclass

//----------------------------TC_APB_WRITE_WITH_STRB_ALL----------------------//

class TC_APB_WRITE_WITH_STRB_ALL extends apb_sequence;
  `uvm_object_utils(TC_APB_WRITE_WITH_STRB_ALL)
  
  function new(string name="TC_APB_WRITE_WITH_STRB_ALL");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 strb  == 4'b1111;});
    
    finish_item(req);
    
  endtask
endclass

//----------------------------TC_APB_WRITE_AFTER_RESET----------------------//

class TC_APB_WRITE_AFTER_RESET extends apb_sequence;
  `uvm_object_utils(TC_APB_WRITE_AFTER_RESET)
  
  function new(string name="TC_APB_WRITE_AFTER_RESET");
    super.new(name);
  endfunction
  
  virtual task body();
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { write == 1;
                                 strb  == 4'b1111; });
    finish_item(req);
    
  endtask
endclass

//----------------------------TC_APB_READ_AFTER_RESET----------------------//

class TC_APB_READ_AFTER_RESET extends apb_sequence;
  `uvm_object_utils(TC_APB_READ_AFTER_RESET)
  
  function new(string name="TC_APB_READ_AFTER_RESET");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { write == 0; });
    finish_item(req);
    
  endtask
endclass

//----------------------------TC_APB_PROT_PRIVILEGED_CHECK------------------//

class TC_APB_PROT_PRIVILEGED_CHECK extends apb_sequence;
  `uvm_object_utils(TC_APB_PROT_PRIVILEGED_CHECK)
  
  function new(string name="TC_APB_PROT_PRIVILEGED_CHECK");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {prot[0] == 1'b0;
                                 write == 1;
                                 strb == 4'b1111;});
    finish_item(req);
    
  endtask
endclass

//----------------------------TC_APB_PROT_SECURE_CHECK------------------//

class TC_APB_PROT_SECURE_CHECK extends apb_sequence;
  `uvm_object_utils(TC_APB_PROT_SECURE_CHECK)
  
  function new(string name="TC_APB_PROT_SECURE_CHECK");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {prot[1] == 1'b1;
                                 write == 1;
                                 strb == 4'b1111;});
    finish_item(req);
    
  endtask
endclass

//----------------------------TC_APB_PROT_INSTR_CHECK------------------//

class TC_APB_PROT_INSTR_CHECK extends apb_sequence;
  `uvm_object_utils(TC_APB_PROT_INSTR_CHECK)
  
  function new(string name="TC_APB_PROT_INSTR_CHECK");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {prot[2] == 1'b1;
                                 write == 1;
                                 strb == 4'b1111;});
    finish_item(req);
    
  endtask
endclass

//----------------------------TC_APB_PROT_COMBINATION------------------//

class TC_APB_PROT_COMBINATION extends apb_sequence;
  `uvm_object_utils(TC_APB_PROT_COMBINATION)
  
  function new(string name="TC_APB_PROT_COMBINATION");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {prot inside {[3'b000:3'b111]};
                                 write == 1;
                                 strb == 4'b1111;});
    finish_item(req);
    
  endtask
endclass

//---------------------------TC_APB_RESET_DURING_ACCESS--------------------//

class TC_APB_RESET_DURING_ACCESS extends apb_sequence;
  `uvm_object_utils(TC_APB_RESET_DURING_ACCESS)
  
  function new(string name="TC_APB_RESET_DURING_ACCESS");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {write == 1;
                                strb == 4'b1111; 
                                addr[15:12] inside {4'h0, 4'h1};
                                addr[1:0] == 2'b00;});
//     req.inject_reset = 1;

    finish_item(req);
    
  endtask
endclass

//--------------------------TC_APB_DATA_STABILITY------------------------//

class TC_APB_DATA_STABILITY extends apb_sequence;
  `uvm_object_utils(TC_APB_DATA_STABILITY)
  
  function new(string name="TC_APB_DATA_STABILITY");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    bit [31:0] saved_addr;
    
    // Write
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write==1; 
                                 strb==4'b1111; });
    saved_addr = req.addr;
    finish_item(req);
    
    // Read back same address
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write==0; 
                                 addr==saved_addr; });
    finish_item(req);
    
  endtask
endclass

//-------------------------TC_RANDOM_READ_WRITE------------------------//

class TC_RANDOM_READ_WRITE extends apb_sequence;
  `uvm_object_utils(TC_RANDOM_READ_WRITE)
  
  function new(string name="TC_RANDOM_READ_WRITE");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    repeat(10) begin
      
      req = apb_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
      
    end
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {write == 1;
                                addr[15:12] inside {[4'h2 : 4'hF]};});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {write == 0;
                                addr[15:12] inside {[4'h2 : 4'hF]};});
    finish_item(req);
    
  endtask
endclass

//-------------------------TC_RANDOM_PSTRB-----------------------------//

class TC_RANDOM_PSTRB extends apb_sequence;
  `uvm_object_utils(TC_RANDOM_PSTRB)
  
  function new(string name="TC_RANDOM_PSTRB");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    repeat(10) begin
      req = apb_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {write == 1;});
      finish_item(req);
    end
    
    req = apb_sequence_item::type_id::create("req");
    req.allow_strb_zero = 1;
    start_item(req);
    assert(req.randomize()with {strb == 4'b0000;
                                addr[15:12] == 4'h1;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    req.allow_strb_zero = 1;
    start_item(req);
    assert(req.randomize()with {strb == 4'b0000;
                                addr[15:12] == 4'h0;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {strb == 4'b1111;
                                addr[15:12] == 4'h1;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {strb == 4'b1111;
                                addr[15:12] == 4'h0;});
    finish_item(req);
    
    begin
      bit [3:0] partial[] = '{4'b0011, 4'b0110, 4'b1100, 4'b0111, 4'b1110, 4'b1011, 4'b1101, 4'b0101, 4'b1010, 4'b1001, 4'b0100, 4'b0010, 4'b1000, 4'b0001};
      
      foreach (partial[i]) begin
        req = apb_sequence_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {write == 1; 
                                     strb == partial[i];
                                     addr[31:16] == 16'h0;
                                     addr[15:12] == 4'h1; 
                                     addr[1:0] == 2'b00;});
        finish_item(req);
      end
    end
    
    begin
      bit [3:0] partial[] = '{4'b0011, 4'b0110, 4'b1100, 4'b0111, 4'b1110, 4'b1011, 4'b1101, 4'b0101, 4'b1010, 4'b1001, 4'b0100, 4'b0010, 4'b1000, 4'b0001};
      
      foreach (partial[i]) begin
        req = apb_sequence_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {write == 1; 
                                     strb == partial[i];
                                     addr[31:16] == 16'h0;
                                     addr[15:12] == 4'h0; 
                                     addr[1:0] == 2'b00;});
        finish_item(req);
      end
    end
    
  endtask
endclass

//--------------------------TC_RANDOM_STRESS--------------------------//

class TC_RANDOM_STRESS extends apb_sequence;
  `uvm_object_utils(TC_RANDOM_STRESS)
  
  function new(string name="TC_RANDOM_STRESS");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    repeat(50) begin
      req = apb_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      finish_item(req);
    end
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {addr[15:12] inside {[4'h2 : 4'hF]};});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    req.allow_strb_zero = 1;
    start_item(req);
    assert(req.randomize()with {strb == 4'b0000;
                                addr[15:12] == 4'h1;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    req.allow_strb_zero = 1;
    start_item(req);
    assert(req.randomize()with {strb == 4'b0000;
                                addr[15:12] == 4'h0;});
    finish_item(req);
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize()with {write == 0;
                                addr[15:12] inside {[4'h2 : 4'hF]};});
    finish_item(req);
    
    begin
      bit [3:0] partial[] = '{4'b0011, 4'b0110, 4'b1100, 4'b0111, 4'b1110, 4'b1011, 4'b1101, 4'b0101, 4'b1010, 4'b1001, 4'b0100, 4'b0010, 4'b1000};
      
      foreach (partial[i]) begin
        req = apb_sequence_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {write == 1; 
                                     strb == partial[i];
                                     addr[31:16] == 16'h0;
                                     addr[15:12] == 4'h1; 
                                     addr[1:0] == 2'b00;});
        finish_item(req);
      end
    end
    
    begin
      bit [3:0] partial[] = '{4'b0011, 4'b0110, 4'b1100, 4'b0111, 4'b1110, 4'b1011, 4'b1101, 4'b0101, 4'b1010, 4'b1001, 4'b0100, 4'b0010, 4'b1000};
      
      foreach (partial[i]) begin
        req = apb_sequence_item::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {write == 1; 
                                     strb == partial[i];
                                     addr[31:16] == 16'h0;
                                     addr[15:12] == 4'h0; 
                                     addr[1:0] == 2'b00;});
        finish_item(req);
      end
    end
    
  endtask
endclass

//-------------------------TC_CONSTR_ADDR-----------------------------//

class TC_CONSTR_ADDR extends apb_sequence;
  `uvm_object_utils(TC_CONSTR_ADDR)
  
  function new(string name="TC_CONSTR_ADDR");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 addr inside {[32'h0 : 32'hFC]};
                                 addr[1:0] == 2'b00;
                                 strb == 4'b1111;});
    finish_item(req);
    
  endtask
endclass

//-------------------------TC_CONSTR_PSTRB---------------------------//

class TC_CONSTR_STRB extends apb_sequence;
  `uvm_object_utils(TC_CONSTR_STRB)
  
  function new(string name="TC_CONSTR_STRB");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 strb inside {4'b0011, 4'b1100};});
    finish_item(req);
    
  endtask
endclass

//-------------------------TC_APB_DONE_PULSE_WIDTH---------------------------//

class TC_APB_DONE_PULSE_WIDTH extends apb_sequence;
  `uvm_object_utils(TC_APB_DONE_PULSE_WIDTH)
  
  function new(string name="TC_APB_DONE_PULSE_WIDTH");
    super.new(name);
  endfunction
  
  virtual task body();
    
    apb_sequence_item req;
    
    req = apb_sequence_item::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {write == 1;
                                 strb == 4'b1111;});
    finish_item(req);
    
  endtask
endclass
