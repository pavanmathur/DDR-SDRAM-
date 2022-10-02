`ifndef _drv_
`define _drv_

`include "ddr_base.sv"

class ddr_drv;
  ddr_base base;
  virtual ddr_intf inf;
  mailbox gen2drv;
  extern function new(ddr_base base,virtual ddr_intf inf,mailbox gen2drv);
  extern task drv_run();
endclass

function ddr_drv :: new(ddr_base base,virtual ddr_intf inf,mailbox gen2drv);
  this.base = base;
  this.inf = inf;
  this.gen2drv = gen2drv;
endfunction

task ddr_drv :: drv_run();
 while(1) begin
  $display($time,"DRIVER :: Run Phase");
  gen2drv.get(base); 
    if(base.RESET_N == 1)
     begin
      inf.ADDR <= base.ADDR;
      inf.DATAIN <= base.DATAIN;
      inf.DM <= base.DM;
      inf.DQ_drv <= base.DQ;
      inf.DQS_drv <= base.DQS;
      inf.CMD <= base.CMD;
        $display($time,"datain=%d,addr=%d,dm=%d,dq=%d,dqs=%d,cmd=%d",base.DATAIN,base.ADDR,base.DM,base.DQ,base.DQS,base.CMD);
     end
    else 
     begin
      inf.ADDR <= base.ADDR;
      inf.DATAIN <= base.DATAIN;
      inf.DM <= base.DM;
      inf.DQ_drv <= base.DQ;
      inf.DQS_drv <= base.DQS;
      inf.CMD <= base.CMD;
     end
    @(posedge inf.CLK or negedge inf.CLK);
    
  end
    
endtask

`endif
      
 
