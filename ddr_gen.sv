`ifndef _gen_
`define _gen_

`include "ddr_base.sv"
`include "configurations.sv"

`define CLK_PERIOD 8

class ddr_gen;
  ddr_base base;
  configurations cfg;
    mailbox gen2drv;
    mailbox gen2sb;
    bit  [`DSIZE-1:0]    DATAINinout;
    bit  [`ASIZE-1:0]    ADDRinout;
    bit  [`DSIZE/8-1:0]  DMinout;
    bit  [`DSIZE/2-1:0]  DQinout;
    bit  [`DSIZE/16-1:0] DQSinout;
    bit  [2:0]           CMDinout;
    int                  a0;
    int                  a1;
    int                  a2;
    int                  a3;
    int                  a4;
    int                  a5;
    
 function new(configurations cfg,mailbox gen2drv,mailbox gen2sb);
   begin
     this.cfg       = cfg;
     this.gen2drv   = gen2drv;
     this.gen2sb    = gen2sb;
     this.DATAINinout = cfg.TXDATAIN;
     this.ADDRinout = cfg.TXADDR;
     this.DMinout   = cfg.TXDM;
     this.DQinout   = cfg.TXDQ;
     this.DQSinout  = cfg.TXDQS;
     this.CMDinout  = cfg.TXCMD;
     a0              = 0;
     a1              = 0;
     a2              = 0;
     a3              = 0;
     a4              = 0;
     a5              = 0;
   end
  endfunction
  
  task run();
    ddr_base base; 
        begin
        $display($time,"GENERATOR :: Run Phase");
        $display("Randomized Configurations=%p",cfg);
        repeat(cfg.num_txns) begin
          case(cfg.cmd1)
            
            cfg.NOP:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.ADDR = calc_addr(cfg);
                  base.DATAIN = calc_din(cfg);
                  base.DM = calc_dm(cfg);
                  base.DQ = calc_dq(cfg);
                  base.DQS = calc_dqs(cfg);
                  base.CMD = $random;//calc_cmd(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                end
                
            cfg.WRITEA:
           repeat(10) begin
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.ADDR = calc_addr(cfg);
                  base.DATAIN = calc_din(cfg);
                  base.DM = calc_dm(cfg);
                  base.DQ = calc_dq(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                
                end
            
                  base.CMD = 3'b010;
                  gen2drv.put(base);
                  gen2sb.put(base);
                end       
                
            cfg.READA:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.ADDR = calc_addr(cfg);
                  base.DQ = calc_dq(cfg);
                  base.DQS = calc_dqs(cfg);
                  base.CMD = calc_cmd(cfg);
                  base.DATAIN = calc_din(cfg);
              
                  gen2drv.put(base);
                  gen2sb.put(base);
               end
               
           
            cfg.REFRESH:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.DQ = calc_dq(cfg);
                  base.CMD = calc_cmd(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                end
                
            cfg.PRECHARGE:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.DQ = calc_dq(cfg);
                  base.CMD = calc_cmd(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                end
                
            cfg.LOAD_MODE:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.DQ = calc_dq(cfg);
                  base.CMD = calc_cmd(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                end
                
            cfg.LOAD_REG2:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.DQ = calc_dq(cfg);
                  base.CMD = calc_cmd(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                end
                
            cfg.LOAD_REG1:
                repeat(10)begin
                  base = new();
                  base.RESET_N = 1'b1;
                  base.DQ = calc_dq(cfg);
                  base.CMD = calc_cmd(cfg);
                  gen2drv.put(base);
                  gen2sb.put(base);
                end
              endcase
            end
          end
        endtask
function bit [`ASIZE-1:0] calc_addr(configurations cfg);
 begin
  case(cfg.ADDR)
	 cfg.random : begin ADDRinout=$random; return ADDRinout; end
	 cfg.constant : begin return ADDRinout; end
	 cfg.incremental: begin  return ADDRinout++; end
	 cfg.decremental: begin return ADDRinout--; end
	 cfg.userpattern: begin ADDRinout = cfg.user_ADDR[a1++]; return ADDRinout; end
	endcase
 end
endfunction

function bit [`DSIZE-1:0] calc_din(configurations cfg);
  begin
    case(cfg.DATAIN)
      cfg.random1 : begin DATAINinout=$random; return DATAINinout; end
      cfg.constant1 : begin return DATAINinout; end
      cfg.incremental1: begin  return DATAINinout++; end
      cfg.decremental1: begin return DATAINinout--; end
      cfg.userpattern1: begin DATAINinout = cfg.user_DATAIN[a0++]; return DATAINinout; end
    endcase
 end
endfunction
function bit [`DSIZE/8-1:0] calc_dm(configurations cfg);
  begin
    case(cfg.DM)
      cfg.random_dm : begin DMinout=$random; return DMinout; end
      cfg.constant_dm : begin return DMinout; end
      cfg.incremental_dm: begin  return DMinout++; end
      cfg.decremental_dm: begin return DMinout--; end
      cfg.userpattern_dm: begin DMinout = cfg.user_DM[a2++]; return DMinout; end
    endcase
 end
endfunction
function bit [`DSIZE/2-1:0] calc_dq(configurations cfg);
  begin
    case(cfg.DQ)
      cfg.random_dq : begin DQinout=$random; return DQinout; end
      cfg.constant_dq : begin return DQinout; end
      cfg.incremental_dq: begin  return DQinout++; end
      cfg.decremental_dq: begin return DQinout--; end
      cfg.userpattern_dq: begin DQinout = cfg.user_DQ[a3++]; return DQinout; end
    endcase
 end
endfunction
function bit [`DSIZE/16-1:0] calc_dqs(configurations cfg);
  begin
    case(cfg.DQS)
      cfg.random_dqs : begin DQSinout=$random; return DQSinout; end
      cfg.constant_dqs : begin return DQSinout; end
      cfg.incremental_dqs: begin  return DQSinout++; end
      cfg.decremental_dqs: begin return DQSinout--; end
      cfg.userpattern_dqs: begin DQinout = cfg.user_DQS[a4++]; return DQSinout; end
    endcase
 end
endfunction
function bit [2:0] calc_cmd(configurations cfg);
  begin
    case(cfg.CMD)
      cfg.random_cmd : begin CMDinout=$random; return CMDinout; end
      cfg.constant_cmd : begin return CMDinout; end
      cfg.incremental_cmd: begin  return CMDinout++; end
      cfg.decremental_cmd: begin return CMDinout--; end
      cfg.userpattern_cmd: begin CMDinout = cfg.user_CMD[a5++]; return CMDinout; end
    endcase
 end
endfunction

endclass
`endif
 
            
              
              

    
