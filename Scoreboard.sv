class apb_sb extends uvm_component;
  `uvm_component_utils(apb_sb)

  uvm_tlm_analysis_fifo #(apb_sequence_item) master_fifo;
  uvm_tlm_analysis_fifo #(apb_sequence_item) slave_fifo[];
  
  logic [7:0] ref_mem [bit[11:0]];
  logic byte_valid [bit[11:0]];

  int pass_count, fail_count, warn_count, skip_count, txn_count;

  function new(string name="apb_sb", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    master_fifo = new("master_fifo", this);
    slave_fifo  = new[2];
    foreach (slave_fifo[i])
      slave_fifo[i] = new($sformatf("slave_fifo[%0d]", i), this);
  endfunction
  
  function automatic bit [11:0] make_key(
    input bit [3:0]  slave_id,
    input bit [31:0] full_addr,
    input int byte_lane);
    
    return {slave_id, full_addr[7:2], 2'(byte_lane)};
  endfunction

  task run_phase(uvm_phase phase);
    apb_sequence_item m_tr, s_tr;
    
    forever begin
      master_fifo.get(m_tr);
      txn_count++;

      s_tr = null;
      
      if (m_tr.addr[15:12] == 4'h0) begin
        fork
          slave_fifo[0].get(s_tr);
          
          begin 
            #500; 
          end
          
        join_any
        disable fork;
      end
          
      else if (m_tr.addr[15:12] == 4'h1) begin
        fork
          slave_fifo[1].get(s_tr);
          
          begin 
            #500; 
          end
          
        join_any
        disable fork;
      end

      if (s_tr == null) begin
        if (m_tr.addr[15:12] > 4'h1) begin
          
          skip_count++;
          
          `uvm_info("SB", $sformatf("[SKIP] Invalid slave addr=0x%08h error=%0b (expected)",m_tr.addr, m_tr.error), UVM_LOW)
          
        end 
        else begin
          warn_count++;
          
          `uvm_warning("SB", $sformatf("[WARN] No slave response for valid addr=0x%08h", m_tr.addr))
          
        end
      end
          
      else begin
        check_transaction(m_tr, s_tr);
      end
    end
          
  endtask

  task check_transaction(apb_sequence_item m_tr, apb_sequence_item s_tr);
    bit [31:0] expected_rdata;
    bit any_byte_valid;
    bit [3:0]  slave_id;
    
    slave_id = m_tr.addr[15:12];

    if (m_tr.error) begin
      skip_count++;
      `uvm_info("SB", $sformatf("[SKIP] PSLVERR=1 ADDR=0x%08h", m_tr.addr), UVM_LOW)
      
      return;
    end

    if (m_tr.write) begin
      if (m_tr.strb == 4'b0000) begin
        warn_count++;
        `uvm_warning("SB", $sformatf("[WARN] STRB=0 write at ADDR=0x%08h", m_tr.addr))
        
        return;
      end
      
      for (int i = 0; i < 4; i++) begin
        if (m_tr.strb[i]) begin
          
          bit [11:0] k = make_key(slave_id, m_tr.addr, i);
          
          ref_mem[k] = m_tr.wdata[8*i +: 8];
          byte_valid[k] = 1;
          
        end
      end
      pass_count++;
      
      `uvm_info("SB", $sformatf("[PASS] WRITE S%0d ADDR=0x%08h (hw_addr=0x%02h) DATA=0x%08h STRB=%04b",slave_id, m_tr.addr, m_tr.addr[7:0], m_tr.wdata, m_tr.strb), UVM_LOW)
      
      return;
    end
    
    expected_rdata = 0;
    any_byte_valid = 0;
    
    for (int i = 0; i < 4; i++) begin
      bit [11:0] k = make_key(slave_id, m_tr.addr, i);
      
      if (byte_valid.exists(k)) begin
        expected_rdata[8*i +: 8] = ref_mem[k];
        any_byte_valid = 1;
        
      end
    end

    if (!any_byte_valid) begin
      if (m_tr.rdata !== 0) begin
        fail_count++;
        `uvm_error("SB", $sformatf("[FAIL] Unwritten READ S%0d ADDR=0x%08h (hw=0x%02h) EXP=0 GOT=0x%08h",slave_id, m_tr.addr, m_tr.addr[7:0], m_tr.rdata))
        
      end else begin
        warn_count++;
        
        `uvm_info("SB", $sformatf("[WARN] Unwritten READ S%0d ADDR=0x%08h got 0x0 (OK)",slave_id, m_tr.addr), UVM_LOW)
        
      end
      return;
    end

    if (m_tr.rdata !== expected_rdata) begin
      fail_count++;
      `uvm_error("SB", $sformatf("[FAIL] READ MISMATCH S%0d ADDR=0x%08h (hw=0x%02h) EXP=0x%08h GOT=0x%08h",slave_id, m_tr.addr, m_tr.addr[7:0], expected_rdata, m_tr.rdata))
      
    end else begin
      pass_count++;
      `uvm_info("SB", $sformatf("[PASS] READ S%0d ADDR=0x%08h DATA=0x%08h",slave_id, m_tr.addr, m_tr.rdata), UVM_LOW)
      
    end

    if (m_tr.error !== s_tr.error) begin
      fail_count++;
      `uvm_error("SB", $sformatf("[FAIL] ERR mismatch master=%0b slave=%0b",m_tr.error, s_tr.error))
      
    end
  endtask

  function void report_phase(uvm_phase phase);
    string sep = "=================================================";
    `uvm_info("SB", sep, UVM_NONE)
    `uvm_info("SB", "-----------------APB SCOREBOARD REPORT------------------", UVM_NONE)
    `uvm_info("SB", sep, UVM_NONE)
    `uvm_info("SB", $sformatf("TOTAL : %0d", txn_count),  UVM_NONE)
    `uvm_info("SB", $sformatf("PASS  : %0d", pass_count), UVM_NONE)
    `uvm_info("SB", $sformatf("FAIL  : %0d", fail_count), UVM_NONE)
    `uvm_info("SB", $sformatf("WARN  : %0d", warn_count), UVM_NONE)
    `uvm_info("SB", $sformatf("SKIP  : %0d", skip_count), UVM_NONE)
    `uvm_info("SB", (fail_count==0) ?"  RESULT:  PASSED " : $sformatf("  RESULT: FAILED (%0d)", fail_count), UVM_NONE)
    `uvm_info("SB", sep, UVM_NONE)
  endfunction
          
  function void clear_ref_mem();
    ref_mem.delete();
    byte_valid.delete();
    `uvm_info("SB", "Scoreboard ref_mem cleared for new test", UVM_LOW)
endfunction : clear_ref_mem
          
endclass
